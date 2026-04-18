require "test_helper"

class AlternativesControllerTest < ActionDispatch::IntegrationTest
  test "easyretro page renders" do
    untenanted do
      get alternative_easyretro_path

      assert_response :success
      assert_in_body "FAST RETRO VS"
      assert_in_body "EasyRetro"
    end
  end

  test "parabol page renders" do
    untenanted do
      get alternative_parabol_path

      assert_response :success
      assert_in_body "Parabol"
    end
  end

  test "metroretro page renders" do
    untenanted do
      get alternative_metroretro_path

      assert_response :success
      assert_in_body "Metro Retro"
    end
  end

  test "teamretro page renders" do
    untenanted do
      get alternative_teamretro_path

      assert_response :success
      assert_in_body "TeamRetro"
    end
  end

  test "quickretro page renders" do
    untenanted do
      get alternative_quickretro_path

      assert_response :success
      assert_in_body "QuickRetro"
    end
  end

  test "reetro page renders" do
    untenanted do
      get alternative_reetro_path

      assert_response :success
      assert_in_body "Reetro"
    end
  end

  test "funretro page renders" do
    untenanted do
      get alternative_funretro_path

      assert_response :success
      assert_in_body "FunRetro"
    end
  end

  test "alternatives redirect authenticated users without account scope" do
    sign_in_as :admin

    untenanted do
      get alternative_easyretro_path

      assert_redirected_to session_menu_url(script_name: nil)
    end
  end

  test "alternative page shows pricing error when stripe price is unavailable" do
    Plan.any_instance.stubs(:price_for_display).raises(Plan::StripePriceUnavailableError.new("Live pricing is currently unavailable. Please try again in a moment."))

    untenanted do
      get alternative_easyretro_path

      assert_response :success
      assert_in_body "Live pricing is currently unavailable. Please try again in a moment."
    end
  end
end
