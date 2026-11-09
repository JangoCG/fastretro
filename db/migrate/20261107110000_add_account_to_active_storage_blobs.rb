class AddAccountToActiveStorageBlobs < ActiveRecord::Migration[8.1]
  def change
    add_reference :active_storage_blobs, :account, foreign_key: { on_delete: :nullify }

    reversible do |direction|
      direction.up do
        execute <<~SQL
          WITH blob_accounts AS (
            SELECT attachments.blob_id, retros.account_id
            FROM active_storage_attachments attachments
            JOIN action_text_rich_texts rich_texts
              ON attachments.record_type = 'ActionText::RichText' AND attachments.record_id = rich_texts.id
            JOIN feedbacks ON rich_texts.record_type = 'Feedback' AND rich_texts.record_id = feedbacks.id
            JOIN retros ON feedbacks.retro_id = retros.id
            UNION ALL
            SELECT attachments.blob_id, retros.account_id
            FROM active_storage_attachments attachments
            JOIN action_text_rich_texts rich_texts
              ON attachments.record_type = 'ActionText::RichText' AND attachments.record_id = rich_texts.id
            JOIN actions ON rich_texts.record_type = 'Action' AND rich_texts.record_id = actions.id
            JOIN retros ON actions.retro_id = retros.id
          ), single_account_blobs AS (
            SELECT blob_id, MIN(account_id) AS account_id
            FROM blob_accounts
            GROUP BY blob_id
            HAVING COUNT(DISTINCT account_id) = 1
          )
          UPDATE active_storage_blobs
          SET account_id = (SELECT account_id FROM single_account_blobs WHERE blob_id = active_storage_blobs.id)
          WHERE id IN (SELECT blob_id FROM single_account_blobs)
        SQL
      end
    end
  end
end
