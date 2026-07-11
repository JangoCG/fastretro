require "application_system_test_case"
require "base64"
require "tempfile"

class LexxyEditorTest < ApplicationSystemTestCase
  test "plain text paste preserves paragraph separation" do
    sign_in_as users(:one)

    visit new_retro_feedback_path(retros(:one), category: :went_well)

    editor = find("lexxy-editor.lexxy-content")
    assert_equal ActiveStorage::UploadLimits::CONTENT_TYPES.join(" "), editor["permitted-attachment-types"]

    within editor do
      assert_selector "button[name='image']"
      assert_no_selector "button[name='file']", visible: true
    end

    editor.click
    paste_text("Hello\n\nWorld")

    within "lexxy-editor" do
      assert_selector "p", count: 2
      assert_selector "p", text: "Hello"
      assert_selector "p", text: "World"
    end
  end

  test "uploads gifs from the image toolbar button" do
    sign_in_as users(:one)

    visit new_retro_feedback_path(retros(:one), category: :went_well)

    editor = find("lexxy-editor.lexxy-content")
    within editor do
      find("button[name='image']").click
    end

    Tempfile.create([ "celebration", ".gif" ]) do |file|
      file.binmode
      file.write(Base64.decode64("R0lGODlhAQABAAAAACwAAAAAAQABAAA="))
      file.flush

      within editor do
        attach_file file.path, make_visible: true
        assert_selector "figure.attachment--gif[data-content-type='image/gif']"
        assert_no_selector "figure.attachment--gif progress"
        assert_no_selector "figure.attachment--error"
      end
    end

    assert ActiveStorage::Blob.exists?(content_type: "image/gif")
  end

  private
    def sign_in_as(user)
      visit session_transfer_url(user.identity.transfer_id, script_name: nil)
      assert_selector "h1", text: "YOUR RETROS"
    end

    def paste_text(text)
      page.execute_script(<<~JS, text)
        const data = new DataTransfer()
        data.setData("text/plain", arguments[0])
        document.activeElement.dispatchEvent(new ClipboardEvent("paste", { clipboardData: data, bubbles: true }))
      JS
    end
end
