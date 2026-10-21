require "hot_cell/client"
require "active_storage/hot_cell/client"

module FastRetro
  module Cell
    NAME = "active_storage"
    TIMEOUT = 135

    class UnprocessableAttachment < StandardError; end
    class ProcessingUnavailable < StandardError; end

    class << self
      def root
        value = ENV["HOTCELL_ROOT"].presence

        if value.nil? && FastRetro.saas? && !Rails.env.local? && !ENV["SECRET_KEY_BASE_DUMMY"]
          raise HotCell::ConfigurationError, "HOTCELL_ROOT must be set for SaaS attachment processing"
        end

        value
      end

      def group
        ENV["HOTCELL_GROUP"].presence
      end

      def enabled?
        root.present?
      end

      def register!
        HotCell.root = root
        HotCell.group = group
        HotCell.register NAME, timeout: TIMEOUT,
          permanent: UnprocessableAttachment, transient: ProcessingUnavailable
      end

      def cell
        HotCell.cell NAME
      end

      def active_storage_configuration
        if enabled?
          { variant_processor: ActiveStorage::HotCell::Client::Transformers::Image::Vips,
            analyzers: [ ActiveStorage::HotCell::Client::Analyzers::Image::Vips,
                         ActiveStorage::HotCell::Client::Analyzers::Video::FFprobe,
                         ActiveStorage::HotCell::Client::Analyzers::Audio::FFprobe ],
            previewers: [ ActiveStorage::HotCell::Client::Previewers::Pdf::Mutool,
                          ActiveStorage::HotCell::Client::Previewers::Video::FFmpeg ] }
        else
          {}
        end
      end
    end
  end
end
