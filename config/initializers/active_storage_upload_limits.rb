module ActiveStorage
  module UploadLimits
    CONTENT_TYPES = %w[ image/gif image/jpeg image/png image/webp ].freeze
    MAX_BYTE_SIZE = 10.megabytes
  end
end

ActiveSupport.on_load(:active_storage_blob) do
  validates :content_type, inclusion: { in: ActiveStorage::UploadLimits::CONTENT_TYPES }
  validates :byte_size, numericality: { less_than_or_equal_to: ActiveStorage::UploadLimits::MAX_BYTE_SIZE }
end
