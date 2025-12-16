require "test_helper"

class RetrosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @retro = retros(:one)
    @identity = identities(:one)
    @account = accounts(:one)
    sign_in_as @identity
  end

  test "should get index" do
    get "#{account_path_prefix(@account)}/retros"
    assert_response :success
  end

  test "should get new" do
    get "#{account_path_prefix(@account)}/retros/new"
    assert_response :success
  end

  test "should create retro" do
    assert_difference("Retro.count") do
      post "#{account_path_prefix(@account)}/retros", params: { retro: { name: @retro.name } }
    end

    assert_response :redirect
  end

  test "should show retro" do
    get "#{account_path_prefix(@account)}/retros/#{@retro.id}"
    assert_response :redirect
  end

  test "should get edit" do
    get "#{account_path_prefix(@account)}/retros/#{@retro.id}/edit"
    assert_response :success
  end

  test "should update retro" do
    patch "#{account_path_prefix(@account)}/retros/#{@retro.id}", params: { retro: { name: @retro.name } }
    assert_response :redirect
  end

  test "should destroy retro" do
    assert_difference("Retro.count", -1) do
      delete "#{account_path_prefix(@account)}/retros/#{@retro.id}"
    end

    assert_response :redirect
  end

  # === CROSS-ACCOUNT ACCESS TESTS ===

  CROSS_ACCOUNT_ALERT = "Retro not found. Either it really does not exist or you are not part of that account"

  test "cross-account access to index redirects with alert" do
    other_account = accounts(:two)

    # User one is signed in but tries to access account two's retros
    get "#{account_path_prefix(other_account)}/retros"

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
  end

  test "cross-account access to show redirects with alert" do
    other_account = accounts(:two)
    other_retro = retros(:other_account_retro)

    get "#{account_path_prefix(other_account)}/retros/#{other_retro.id}"

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
  end

  test "cross-account access to new redirects with alert" do
    other_account = accounts(:two)

    get "#{account_path_prefix(other_account)}/retros/new"

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
  end

  test "cross-account access to create redirects with alert" do
    other_account = accounts(:two)

    assert_no_difference("Retro.count") do
      post "#{account_path_prefix(other_account)}/retros", params: { retro: { name: "Sneaky Retro" } }
    end

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
  end

  test "cross-account access to edit redirects with alert" do
    other_account = accounts(:two)
    other_retro = retros(:other_account_retro)

    get "#{account_path_prefix(other_account)}/retros/#{other_retro.id}/edit"

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
  end

  test "cross-account access to update redirects with alert" do
    other_account = accounts(:two)
    other_retro = retros(:other_account_retro)

    patch "#{account_path_prefix(other_account)}/retros/#{other_retro.id}", params: { retro: { name: "Hacked Name" } }

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
    assert_equal "Other Account Retro", other_retro.reload.name, "Retro name should not be changed"
  end

  test "cross-account access to destroy redirects with alert" do
    other_account = accounts(:two)
    other_retro = retros(:other_account_retro)

    assert_no_difference("Retro.count") do
      delete "#{account_path_prefix(other_account)}/retros/#{other_retro.id}"
    end

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
  end

  test "user from other account cannot access retros via URL manipulation" do
    # Clear previous session and sign in as user from account two
    logout_and_sign_in_as :other

    # Try to access account one's retros
    get "#{account_path_prefix(@account)}/retros"

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
  end

  test "user from other account cannot view specific retro via URL manipulation" do
    logout_and_sign_in_as :other

    get "#{account_path_prefix(@account)}/retros/#{@retro.id}"

    assert_redirected_to session_menu_url(script_name: nil)
    assert_equal CROSS_ACCOUNT_ALERT, flash[:alert]
  end
end
