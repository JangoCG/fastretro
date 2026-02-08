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

  test "alternatives redirect authenticated users without account scope" do
    sign_in_as :admin

    untenanted do
      get alternative_easyretro_path

      assert_redirected_to session_menu_url(script_name: nil)
    end
  end
end
