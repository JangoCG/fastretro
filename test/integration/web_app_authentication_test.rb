require "test_helper"

class WebAppAuthenticationTest < ActionDispatch::IntegrationTest
  test "API token management and identity discovery are unavailable even when signed in" do
    sign_in_as :admin

    [ "", accounts(:one).slug ].each do |prefix|
      [ "/my/identity.json", "/my/access_tokens", "/my/access_tokens/new", "/my/access_tokens/1" ].each do |path|
        get "#{prefix}#{path}"
        assert_response :not_found
      end
      post "#{prefix}/my/access_tokens", params: { access_token: { description: "Unused", permission: "write" } }, as: :json
      assert_response :not_found
      delete "#{prefix}/my/access_tokens/1", as: :json
      assert_response :not_found
    end
  end

  test "authorization headers do not replace a browser session" do
    get retros_path, headers: { "Authorization" => "Bearer unused-token" }, as: :json
    assert_redirected_to root_path(script_name: nil)
    assert cookies[:session_token].blank?
  end

  test "authorization headers do not override an existing browser session" do
    sign_in_as :admin
    get retros_path, headers: { "Authorization" => "Bearer unused-token" }
    assert_response :success
  end

  test "JSON login requests use redirects and cookies without returning credentials" do
    untenanted do
      post session_path, params: { email_address: identities(:admin).email_address }, as: :json
      assert_redirected_to session_magic_link_path
      assert cookies[:pending_authentication_token].present?
      assert_not_includes response.body, cookies[:pending_authentication_token]

      magic_link = identities(:admin).magic_links.order(:id).last
      post session_magic_link_path, params: { code: magic_link.code }, as: :json
      assert_redirected_to session_menu_path
      assert cookies[:session_token].present?
      assert_not_includes response.body, cookies[:session_token]
      assert_not MagicLink.exists?(magic_link.id)

      delete session_path, as: :json
      assert_redirected_to root_path
      assert cookies[:session_token].blank?
    end
  end
end
