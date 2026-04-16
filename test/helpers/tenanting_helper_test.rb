require "test_helper"

class TenantingHelperTest < ActionView::TestCase
  test "emits action-cable-url prefixed with the request script_name" do
    request.script_name = "/1000001"

    assert_equal(
      %(<meta name="action-cable-url" content="/1000001/cable" />),
      tenanted_action_cable_meta_tag
    )
  end

  test "falls back to the bare mount path when no script_name is set" do
    request.script_name = ""

    assert_equal(
      %(<meta name="action-cable-url" content="/cable" />),
      tenanted_action_cable_meta_tag
    )
  end
end
