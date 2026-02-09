# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_09_103500) do
  create_table "account_billing_waivers", force: :cascade do |t|
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_billing_waivers_on_account_id", unique: true
  end

  create_table "account_external_id_sequences", force: :cascade do |t|
    t.bigint "value", default: 0, null: false
    t.index ["value"], name: "index_account_external_id_sequences_on_value", unique: true
  end

  create_table "account_join_codes", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "usage_count", default: 0, null: false
    t.integer "usage_limit", default: 10, null: false
    t.index ["account_id"], name: "index_account_join_codes_on_account_id"
    t.index ["code"], name: "index_account_join_codes_on_code", unique: true
  end

  create_table "account_subscriptions", force: :cascade do |t|
    t.integer "account_id", null: false
    t.datetime "cancel_at"
    t.datetime "created_at", null: false
    t.datetime "current_period_end"
    t.integer "next_amount_due_in_cents"
    t.string "plan_key"
    t.string "status"
    t.string "stripe_customer_id"
    t.string "stripe_subscription_id"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_subscriptions_on_account_id"
    t.index ["stripe_customer_id"], name: "index_account_subscriptions_on_stripe_customer_id", unique: true
    t.index ["stripe_subscription_id"], name: "index_account_subscriptions_on_stripe_subscription_id", unique: true
  end

  create_table "accounts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "external_account_id", null: false
    t.integer "feedbacks_count", default: 0, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["external_account_id"], name: "index_accounts_on_external_account_id", unique: true
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "actions", force: :cascade do |t|
    t.boolean "completed", default: false, null: false
    t.datetime "created_at", null: false
    t.integer "retro_id", null: false
    t.string "status", default: "drafted"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["retro_id"], name: "index_actions_on_retro_id"
    t.index ["user_id"], name: "index_actions_on_user_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "feedback_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "retro_id", null: false
    t.datetime "updated_at", null: false
    t.index ["retro_id"], name: "index_feedback_groups_on_retro_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.integer "feedback_group_id"
    t.integer "retro_id", null: false
    t.string "status", default: "drafted", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["feedback_group_id"], name: "index_feedbacks_on_feedback_group_id"
    t.index ["retro_id"], name: "index_feedbacks_on_retro_id"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "identities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.integer "lifetime_feedbacks_count", default: 0, null: false
    t.boolean "staff", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_identities_on_email_address", unique: true
  end

  create_table "magic_links", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.integer "identity_id", null: false
    t.integer "purpose", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_magic_links_on_code", unique: true
    t.index ["expires_at"], name: "index_magic_links_on_expires_at"
    t.index ["identity_id"], name: "index_magic_links_on_identity_id"
  end

  create_table "retro_participants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "finished", default: false, null: false
    t.integer "retro_id", null: false
    t.string "role", default: "participant", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["retro_id", "user_id"], name: "index_retro_participants_on_retro_id_and_user_id", unique: true
    t.index ["retro_id"], name: "index_retro_participants_on_retro_id"
    t.index ["user_id"], name: "index_retro_participants_on_user_id"
  end

  create_table "retros", force: :cascade do |t|
    t.integer "account_id", null: false
    t.json "column_layout", default: [], null: false
    t.datetime "created_at", null: false
    t.integer "highlighted_user_id"
    t.string "layout_mode", default: "default", null: false
    t.boolean "music_playing", default: false, null: false
    t.string "name"
    t.string "phase", default: "waiting_room", null: false
    t.datetime "updated_at", null: false
    t.integer "votes_per_participant", default: 3, null: false
    t.index ["account_id"], name: "index_retros_on_account_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "identity_id", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["identity_id"], name: "index_sessions_on_identity_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "account_id"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.integer "identity_id"
    t.string "name", null: false
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.datetime "verified_at"
    t.index ["account_id", "identity_id"], name: "index_users_on_account_id_and_identity_id", unique: true
    t.index ["account_id", "role"], name: "index_users_on_account_id_and_role"
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["identity_id"], name: "index_users_on_identity_id"
  end

  create_table "votes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "retro_participant_id", null: false
    t.datetime "updated_at", null: false
    t.integer "voteable_id", null: false
    t.string "voteable_type", null: false
    t.index ["retro_participant_id"], name: "index_votes_on_retro_participant_id"
    t.index ["voteable_type", "voteable_id"], name: "index_votes_on_voteable"
  end

  add_foreign_key "account_billing_waivers", "accounts"
  add_foreign_key "account_join_codes", "accounts"
  add_foreign_key "account_subscriptions", "accounts"
  add_foreign_key "actions", "retros"
  add_foreign_key "actions", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "feedback_groups", "retros"
  add_foreign_key "feedbacks", "feedback_groups"
  add_foreign_key "feedbacks", "retros"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "magic_links", "identities"
  add_foreign_key "retro_participants", "retros"
  add_foreign_key "retro_participants", "users"
  add_foreign_key "retros", "accounts"
  add_foreign_key "sessions", "identities"
  add_foreign_key "users", "accounts"
  add_foreign_key "users", "identities"
  add_foreign_key "votes", "retro_participants"
end
