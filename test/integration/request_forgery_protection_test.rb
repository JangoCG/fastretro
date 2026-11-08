require "test_helper"

class RequestForgeryProtectionTest < ActionDispatch::IntegrationTest
  setup do
    @original_forgery_protection = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    https!
  end

  teardown do
    ActionController::Base.allow_forgery_protection = @original_forgery_protection
  end

  test "JSON requests without fetch metadata cannot bypass CSRF protection" do
    untenanted do
      assert_no_difference "MagicLink.count" do
        without_action_dispatch_exception_handling do
          assert_raises ActionController::InvalidAuthenticityToken do
            post session_path, params: { email_address: identities(:admin).email_address }, as: :json
          end
        end
      end
      assert cookies[:pending_authentication_token].blank?
    end
  end

  test "same origin browser JSON still signs in uploads and updates profiles" do
    headers = { "Sec-Fetch-Site" => "same-origin" }
    untenanted do
      post session_path, params: { email_address: identities(:admin).email_address }, headers: headers, as: :json
      assert_redirected_to session_magic_link_path
      link = identities(:admin).magic_links.order(:id).last
      post session_magic_link_path, params: { code: link.code }, headers: headers, as: :json
      assert_redirected_to session_menu_path
      assert cookies[:session_token].present?
    end

    patch user_path(users(:admin), script_name: accounts(:one).slug),
      params: { user: { name: "Browser JSON update" } }, headers: headers, as: :json
    assert_response :no_content
    assert_equal "Browser JSON update", users(:admin).reload.name

    post "#{accounts(:one).slug}/rails/active_storage/direct_uploads", params: {
      blob: { filename: "image.png", content_type: "image/png", byte_size: 1, checksum: Digest::MD5.base64digest("x") }
    }, headers: headers, as: :json
    assert_response :success
    blob = ActiveStorage::Blob.find_signed!(response.parsed_body.fetch("signed_id"))
    assert_equal accounts(:one).id, blob.account_id
  end

  test "a mismatched origin cannot bypass CSRF with same origin fetch metadata" do
    untenanted do
      assert_no_difference "MagicLink.count" do
        without_action_dispatch_exception_handling do
          assert_raises ActionController::InvalidAuthenticityToken do
            post session_path, params: { email_address: identities(:admin).email_address }, as: :json,
              headers: { "Sec-Fetch-Site" => "same-origin", "Origin" => "https://foreign.example" }
          end
        end
      end
    end
  end

  test "HTTP forms need no metadata only when secure protocol is disabled" do
    original_secure_protocol = ActionDispatch::Http::URL.secure_protocol
    https! false
    untenanted do
      ActionDispatch::Http::URL.secure_protocol = false
      post session_path, params: { email_address: identities(:admin).email_address }
      assert_redirected_to session_magic_link_path

      ActionDispatch::Http::URL.secure_protocol = true
      without_action_dispatch_exception_handling do
        assert_raises ActionController::InvalidAuthenticityToken do
          post session_path, params: { email_address: identities(:admin).email_address }
        end
      end
    end
  ensure
    ActionDispatch::Http::URL.secure_protocol = original_secure_protocol
  end

  test "browser fetch metadata permits same origin and refuses cross site requests" do
    untenanted do
      %w[ same-origin same-site ].each do |site|
        post session_path, params: { email_address: identities(:admin).email_address }, headers: { "Sec-Fetch-Site" => site }
        assert_redirected_to session_magic_link_path
        assert_includes response.headers["Vary"], "Sec-Fetch-Site"
      end

      without_action_dispatch_exception_handling do
        [ "cross-site", "none", "invalid" ].each do |site|
          assert_raises ActionController::InvalidAuthenticityToken do
            post session_path, params: { email_address: identities(:admin).email_address }, as: :json, headers: { "Sec-Fetch-Site" => site }
          end
        end
        assert_raises ActionController::InvalidAuthenticityToken do
          post session_path, params: { email_address: identities(:admin).email_address }
        end
      end
    end
  end
end
