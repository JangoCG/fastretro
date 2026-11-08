require "test_helper"

class Users::EmailAddressesControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup do
    @user = users(:two)
    sign_in_as :two
  end

  test "the web form rejects invalid same and duplicate email addresses before queueing confirmation" do
    [
      [ "notanemail", "Please enter a valid email address" ],
      [ @user.identity.email_address, "That is already your email address" ],
      [ @user.identity.email_address.upcase, "That is already your email address" ],
      [ identities(:admin).email_address, "You already have a user in this account with that email address" ]
    ].each do |email, message|
      assert_no_enqueued_emails do
        post user_email_addresses_path(@user), params: { email_address: email }
      end
      assert_redirected_to new_user_email_address_path(@user)
      assert_equal message, flash[:alert]
    end
  end

  test "a valid web form submission sends a usable confirmation for the selected membership" do
    assert_emails 1 do
      post user_email_addresses_path(@user), params: { email_address: "newemail@example.com" }
    end
    assert_response :success
    mail = ActionMailer::Base.deliveries.last
    assert_equal [ "newemail@example.com" ], mail.to
    assert_equal identities(:two), @user.reload.identity
    confirmation_url = Nokogiri::HTML.fragment(mail.body.encoded).at_css("a[href*='/email_addresses/']")["href"]
    assert_includes confirmation_url, "#{accounts(:one).slug}/users/#{@user.id}/email_addresses/"
    post confirmation_url
    assert_redirected_to edit_user_url(@user)
    assert_equal "newemail@example.com", @user.reload.identity.email_address
  end

  test "an email belonging only to another account can receive confirmation" do
    assert_enqueued_emails 1 do
      post user_email_addresses_path(@user), params: { email_address: identities(:other).email_address }
    end
    assert_response :success
    assert_equal identities(:two), @user.reload.identity
  end

  test "a caller cannot request confirmation for someone else's membership" do
    assert_no_enqueued_emails do
      post user_email_addresses_path(users(:admin)), params: { email_address: "newemail@example.com" }
    end
    assert_response :not_found
  end

  test "blank email parameters return bad request without queueing mail" do
    assert_no_enqueued_emails do
      post user_email_addresses_path(@user), params: { email_address: "" }
    end
    assert_response :bad_request
  end
end
