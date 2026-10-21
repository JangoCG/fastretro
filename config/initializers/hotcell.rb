require_relative "../../lib/fastretro/unprocessable_attachments"

Rails.application.config.to_prepare { FastRetro::UnprocessableAttachments.install! }
