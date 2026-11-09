ActiveSupport.on_load(:action_text_rich_text) do
  delegate :account, to: :record

  def accessible_to?(user)
    record.try(:accessible_to?, user)
  end
end
