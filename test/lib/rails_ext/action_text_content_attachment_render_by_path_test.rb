require "test_helper"

class ActionTextContentAttachmentRenderByPathTest < ActiveSupport::TestCase
  test "renders nested content outside a controller" do
    html = %(<action-text-attachment content-type="text/html" content="&lt;p&gt;abc&lt;/p&gt;"></action-text-attachment>)
    assert_equal "<p>abc</p>", ActionText::Content.new(html).attachables.sole.to_html.strip
  end
end
