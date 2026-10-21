require "hot_cell/client"
require "active_storage/hot_cell/client"

module FastRetro
  module Cell
    NAME = "active_storage"
    TIMEOUT = 45

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

      def enabled?
        root.present?
      end

      def register!
        HotCell.root = root
        HotCell.group = ENV["HOTCELL_GROUP"].presence
        HotCell.register NAME, timeout: TIMEOUT,
          permanent: UnprocessableAttachment, transient: ProcessingUnavailable
      end

      def active_storage_configuration
        if enabled?
          { variant_processor: ActiveStorage::HotCell::Client::Transformers::Image::Vips,
            analyzers: [ ActiveStorage::HotCell::Client::Analyzers::Image::Vips ],
            previewers: [] }
        else
          {}
        end
      end
    end
  end
end
