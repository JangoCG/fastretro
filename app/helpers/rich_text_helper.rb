module RichTextHelper
  def rich_text_editor_options(**overrides)
    {
      attachments: true,
      "permitted-attachment-types": ActiveStorage::UploadLimits::CONTENT_TYPES.join(" ")
    }.merge(overrides)
  end
end
