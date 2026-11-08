require "test_helper"
require Rails.root.join("db/migrate/20261107110000_add_account_to_active_storage_blobs")

class AddAccountToActiveStorageBlobsTest < ActiveSupport::TestCase
  class MigrationRecord < ActiveRecord::Base
    self.abstract_class = true
  end

  test "migration attributes existing embeds to their account and reverses without losing blobs" do
    MigrationRecord.establish_connection(adapter: "sqlite3", database: ":memory:")
    connection = MigrationRecord.lease_connection
    connection.create_table(:accounts)
    connection.create_table(:retros) { |table| table.integer :account_id }
    connection.create_table(:feedbacks) { |table| table.integer :retro_id }
    connection.create_table(:actions) { |table| table.integer :retro_id }
    connection.create_table(:action_text_rich_texts) do |table|
      table.string :record_type
      table.integer :record_id
    end
    connection.create_table(:active_storage_attachments) do |table|
      table.string :record_type
      table.integer :record_id
      table.integer :blob_id
    end
    connection.create_table(:active_storage_blobs)

    connection.execute "INSERT INTO accounts (id) VALUES (1), (2)"
    connection.execute "INSERT INTO retros (id, account_id) VALUES (1, 1), (2, 2)"
    connection.execute "INSERT INTO feedbacks (id, retro_id) VALUES (1, 1), (2, 2)"
    connection.execute "INSERT INTO actions (id, retro_id) VALUES (1, 2)"
    connection.execute "INSERT INTO action_text_rich_texts (id, record_type, record_id) VALUES (1, 'Feedback', 1), (2, 'Feedback', 2), (3, 'Action', 1)"
    connection.execute "INSERT INTO active_storage_blobs (id) VALUES (1), (2), (3), (4)"
    connection.execute <<~SQL
      INSERT INTO active_storage_attachments (record_type, record_id, blob_id)
      VALUES ('ActionText::RichText', 1, 1), ('ActionText::RichText', 3, 2),
             ('ActionText::RichText', 1, 3), ('ActionText::RichText', 2, 3)
    SQL

    migration = AddAccountToActiveStorageBlobs.new
    migration.suppress_messages { migration.exec_migration(connection, :up) }

    assert_equal [ [ 1, 1 ], [ 2, 2 ], [ 3, nil ], [ 4, nil ] ],
      connection.select_rows("SELECT id, account_id FROM active_storage_blobs ORDER BY id")

    connection.execute "DELETE FROM accounts WHERE id = 2"
    assert_nil connection.select_value("SELECT account_id FROM active_storage_blobs WHERE id = 2")

    migration.suppress_messages { migration.exec_migration(connection, :down) }
    assert_not connection.column_exists?(:active_storage_blobs, :account_id)
    assert_equal 4, connection.select_value("SELECT COUNT(*) FROM active_storage_blobs")
  ensure
    MigrationRecord.remove_connection
  end
end
