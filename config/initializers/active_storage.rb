ActiveSupport.on_load(:active_storage_blob) do
  belongs_to :account, default: -> { Current.account }, optional: true
end

ActiveSupport.on_load(:action_text_content) do
  ActiveSupport.on_load(:active_storage_blob) do
    def to_rich_text_attributes(*)
      super.merge url: Rails.application.routes.url_helpers.polymorphic_url(self, only_path: true, script_name: Current.account&.slug)
    end
  end
end

ActiveSupport.on_load(:active_storage_attachment) do
  validate :blob_account_matches_record, on: :create

  private
    def blob_account_matches_record
      if record&.try(:account).present? && blob&.account_id != record.account.id
        errors.add(:blob_id, "blob account must match record account")
      end
    end
end
