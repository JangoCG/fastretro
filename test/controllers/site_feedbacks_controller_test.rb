require "test_helper"

class SiteFeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "unauthenticated user can access feedback form" do
    untenanted do
      get new_site_feedback_path
    end

    assert_response :success
    assert_in_body "Send us Feedback"
  end

  test "authenticated user can access feedback form" do
    sign_in_as :one

    untenanted do
      get new_site_feedback_path
    end

    assert_response :success
    assert_in_body "Send us Feedback"
  end

  test "unauthenticated user must provide email" do
    untenanted do
      post site_feedback_path, params: { message: "Great app!", name: "Test User" }
    end

    assert_response :unprocessable_entity
    assert_in_body "Please enter your email address"
  end

  test "unauthenticated user can submit feedback with email" do
    assert_enqueued_emails 1 do
      untenanted do
        post site_feedback_path, params: {
          message: "Great app!",
          name: "Test User",
          email: "test@example.com"
        }
      end
    end

    assert_redirected_to new_site_feedback_url(script_name: nil)
    assert_equal "Thanks for your feedback! We'll get back to you soon.", flash[:notice]
  end

  test "authenticated user can submit feedback without providing email" do
    sign_in_as :one

    assert_enqueued_emails 1 do
      untenanted do
        post site_feedback_path, params: { message: "Love this app!" }
      end
    end

    assert_redirected_to new_site_feedback_url(script_name: nil)
    assert_equal "Thanks for your feedback! We'll get back to you soon.", flash[:notice]
  end

  test "empty message shows error" do
    sign_in_as :one

    untenanted do
      post site_feedback_path, params: { message: "" }
    end

    assert_response :unprocessable_entity
    assert_in_body "Please enter a message"
  end
end
