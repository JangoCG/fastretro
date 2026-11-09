require "test_helper"

class RichTextSanitizationTest < ActionView::TestCase
  test "rich text retains supported disclosure table and video markup while removing executable markup" do
    html = <<~HTML
      <details onclick="alert(1)"><summary>Decisions</summary><s>Old decision</s></details>
      <table><thead><tr><th>Action</th></tr></thead><tbody><tr><td>Follow up</td></tr></tbody></table>
      <video controls width="320"><source src="/clip.mp4" type="video/mp4"></video>
      <script>alert(1)</script><a href="javascript:alert(1)">Unsafe link</a>
    HTML
    render partial: "action_text/contents/content", formats: :html, locals: { content: ActionText::Content.new(html) }
    assert_select "details summary", text: "Decisions"
    assert_select "s", text: "Old decision"
    assert_select "table thead th", text: "Action"
    assert_select "table tbody td", text: "Follow up"
    assert_select "video[controls][width='320'] source[src='/clip.mp4'][type='video/mp4']"
    assert_select "script, [onclick], a[href^='javascript:']", count: 0
  end
end
