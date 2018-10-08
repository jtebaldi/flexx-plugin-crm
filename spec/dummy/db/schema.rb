# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20181008102608) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "automated_campaign_jobs", force: :cascade do |t|
    t.integer  "site_id",                    null: false
    t.integer  "automated_campaign_id",      null: false
    t.integer  "automated_campaign_step_id", null: false
    t.integer  "contact_id",                 null: false
    t.string   "status",                     null: false
    t.string   "send_to",                    null: false
    t.datetime "send_at",                    null: false
    t.text     "message",                    null: false
    t.datetime "status_changed_at",          null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "automated_campaign_steps", force: :cascade do |t|
    t.integer  "automated_campaign_id",                null: false
    t.integer  "created_by",                           null: false
    t.string   "name",                                 null: false
    t.integer  "due_on_value",                         null: false
    t.string   "due_on_unit",                          null: false
    t.text     "message",                              null: false
    t.boolean  "enabled",               default: true
    t.integer  "disable_by"
    t.datetime "disabled_at"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "automated_campaign_to_contact_form_associations", force: :cascade do |t|
    t.integer  "automated_campaign_id"
    t.integer  "cama_contact_form_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "automated_campaigns", force: :cascade do |t|
    t.integer  "site_id",                     null: false
    t.string   "name",                        null: false
    t.boolean  "archived",    default: false
    t.integer  "archived_by"
    t.datetime "archived_at"
    t.boolean  "paused",      default: true
    t.integer  "paused_by"
    t.datetime "paused_at"
    t.integer  "created_by"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "comments", force: :cascade do |t|
    t.string   "author"
    t.string   "author_email"
    t.string   "author_url"
    t.string   "author_IP"
    t.text     "content"
    t.string   "approved",       default: "pending"
    t.string   "agent"
    t.string   "typee"
    t.integer  "comment_parent"
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "comments", ["approved"], name: "index_comments_on_approved", using: :btree
  add_index "comments", ["comment_parent"], name: "index_comments_on_comment_parent", using: :btree
  add_index "comments", ["post_id"], name: "index_comments_on_post_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "contacts", force: :cascade do |t|
    t.integer  "site_id"
    t.string   "sendgrid_id"
    t.string   "source"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "sales_stage"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "cama_contact_form_id"
    t.text     "highlights"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "country"
    t.date     "birthday"
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  add_index "contacts", ["site_id", "email"], name: "index_contacts_on_site_id_and_email", unique: true, using: :btree

  create_table "custom_fields", force: :cascade do |t|
    t.string  "object_class"
    t.string  "name"
    t.string  "slug"
    t.integer "objectid"
    t.integer "parent_id"
    t.integer "field_order"
    t.integer "count",        default: 0
    t.boolean "is_repeat",    default: false
    t.text    "description"
    t.string  "status"
  end

  add_index "custom_fields", ["object_class"], name: "index_custom_fields_on_object_class", using: :btree
  add_index "custom_fields", ["objectid"], name: "index_custom_fields_on_objectid", using: :btree
  add_index "custom_fields", ["parent_id"], name: "index_custom_fields_on_parent_id", using: :btree
  add_index "custom_fields", ["slug"], name: "index_custom_fields_on_slug", using: :btree

  create_table "custom_fields_relationships", force: :cascade do |t|
    t.integer "objectid"
    t.integer "custom_field_id"
    t.integer "term_order"
    t.string  "object_class"
    t.text    "value"
    t.string  "custom_field_slug"
    t.integer "group_number",      default: 0
  end

  add_index "custom_fields_relationships", ["custom_field_id"], name: "index_custom_fields_relationships_on_custom_field_id", using: :btree
  add_index "custom_fields_relationships", ["custom_field_slug"], name: "index_custom_fields_relationships_on_custom_field_slug", using: :btree
  add_index "custom_fields_relationships", ["object_class"], name: "index_custom_fields_relationships_on_object_class", using: :btree
  add_index "custom_fields_relationships", ["objectid"], name: "index_custom_fields_relationships_on_objectid", using: :btree

  create_table "email_recipients", force: :cascade do |t|
    t.string "email_id"
    t.string "to"
    t.string "status"
  end

  create_table "emails", force: :cascade do |t|
    t.string   "sg_message_id"
    t.integer  "site_id"
    t.string   "subject"
    t.text     "body"
    t.integer  "created_by"
    t.string   "aasm_state"
    t.datetime "send_at"
  end

  add_index "emails", ["sg_message_id"], name: "index_emails_on_sg_message_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "contact_id"
    t.integer  "site_id"
    t.string   "sid"
    t.string   "from_number"
    t.string   "to_number"
    t.text     "message"
    t.string   "status"
    t.integer  "created_by"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "read",        default: false
    t.string   "aasm_state"
    t.datetime "send_at"
  end

  add_index "messages", ["contact_id"], name: "index_messages_on_contact_id", using: :btree
  add_index "messages", ["created_at"], name: "index_messages_on_created_at", using: :btree
  add_index "messages", ["from_number"], name: "index_messages_on_from_number", using: :btree
  add_index "messages", ["read"], name: "index_messages_on_read", using: :btree
  add_index "messages", ["site_id"], name: "index_messages_on_site_id", using: :btree
  add_index "messages", ["to_number"], name: "index_messages_on_to_number", using: :btree

  create_table "metas", force: :cascade do |t|
    t.string  "key"
    t.text    "value"
    t.integer "objectid"
    t.string  "object_class"
  end

  add_index "metas", ["key"], name: "index_metas_on_key", using: :btree
  add_index "metas", ["object_class"], name: "index_metas_on_object_class", using: :btree
  add_index "metas", ["objectid"], name: "index_metas_on_objectid", using: :btree

  create_table "notes", force: :cascade do |t|
    t.string   "details"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.integer  "created_by"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "notes", ["parent_type", "parent_id"], name: "index_notes_on_parent_type_and_parent_id", using: :btree

  create_table "phonenumbers", force: :cascade do |t|
    t.integer  "contact_id", null: false
    t.string   "number",     null: false
    t.string   "phone_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "site_id"
  end

  add_index "phonenumbers", ["site_id", "number"], name: "index_phonenumbers_on_site_id_and_number", unique: true, using: :btree

  create_table "plugins_contact_forms", force: :cascade do |t|
    t.integer  "site_id"
    t.integer  "count"
    t.integer  "parent_id"
    t.string   "name"
    t.string   "slug"
    t.text     "description"
    t.text     "value"
    t.text     "settings"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", force: :cascade do |t|
    t.string   "title"
    t.string   "slug"
    t.text     "content"
    t.text     "content_filtered"
    t.string   "status",           default: "published"
    t.datetime "published_at"
    t.integer  "post_parent"
    t.string   "visibility",       default: "public"
    t.text     "visibility_value"
    t.string   "post_class",       default: "Post"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "user_id"
    t.integer  "post_order",       default: 0
    t.integer  "taxonomy_id"
    t.boolean  "is_feature",       default: false
  end

  add_index "posts", ["post_class"], name: "index_posts_on_post_class", using: :btree
  add_index "posts", ["post_parent"], name: "index_posts_on_post_parent", using: :btree
  add_index "posts", ["slug"], name: "index_posts_on_slug", using: :btree
  add_index "posts", ["status"], name: "index_posts_on_status", using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "stocks", force: :cascade do |t|
    t.integer  "site_id"
    t.string   "stock_type",               null: false
    t.string   "label"
    t.string   "description"
    t.text     "contents",                 null: false
    t.json     "metadata",    default: {}
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.boolean  "starred"
    t.string   "name",                     null: false
  end

  add_index "stocks", ["label"], name: "index_stocks_on_label", using: :btree
  add_index "stocks", ["site_id", "label"], name: "index_stocks_on_site_id_and_label", unique: true, using: :btree
  add_index "stocks", ["site_id"], name: "index_stocks_on_site_id", using: :btree
  add_index "stocks", ["stock_type"], name: "index_stocks_on_stock_type", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["context"], name: "index_taggings_on_context", using: :btree
  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy", using: :btree
  add_index "taggings", ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree
  add_index "taggings", ["taggable_type"], name: "index_taggings_on_taggable_type", using: :btree
  add_index "taggings", ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type", using: :btree
  add_index "taggings", ["tagger_id"], name: "index_taggings_on_tagger_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "task_owners", force: :cascade do |t|
    t.integer  "task_id",    null: false
    t.integer  "owner_id",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "task_recipe_directions", force: :cascade do |t|
    t.integer  "task_recipe_id"
    t.string   "task_type"
    t.integer  "due_on_value",   default: 0,         null: false
    t.string   "due_on_unit",    default: "minutes", null: false
    t.string   "title"
    t.string   "details"
    t.integer  "created_by"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "task_recipe_to_contact_form_associations", force: :cascade do |t|
    t.integer  "task_recipe_id"
    t.integer  "cama_contact_form_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "task_recipes", force: :cascade do |t|
    t.string   "title"
    t.integer  "created_by"
    t.integer  "site_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "archived",    default: false
    t.integer  "archived_by"
    t.datetime "archived_at"
    t.boolean  "paused",      default: true
    t.integer  "paused_by"
    t.datetime "paused_at"
    t.string   "description"
  end

  create_table "tasks", force: :cascade do |t|
    t.integer  "contact_id"
    t.integer  "site_id"
    t.string   "task_type"
    t.string   "title"
    t.string   "details"
    t.datetime "due_date"
    t.string   "aasm_state"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.datetime "confirmed_at"
  end

  create_table "term_relationships", force: :cascade do |t|
    t.integer "objectid"
    t.integer "term_order"
    t.integer "term_taxonomy_id"
  end

  add_index "term_relationships", ["objectid"], name: "index_term_relationships_on_objectid", using: :btree
  add_index "term_relationships", ["term_order"], name: "index_term_relationships_on_term_order", using: :btree
  add_index "term_relationships", ["term_taxonomy_id"], name: "index_term_relationships_on_term_taxonomy_id", using: :btree

  create_table "term_taxonomy", force: :cascade do |t|
    t.string   "taxonomy"
    t.text     "description"
    t.integer  "parent_id"
    t.integer  "count"
    t.string   "name"
    t.string   "slug"
    t.integer  "term_group"
    t.integer  "term_order"
    t.string   "status"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "user_id"
  end

  add_index "term_taxonomy", ["parent_id"], name: "index_term_taxonomy_on_parent_id", using: :btree
  add_index "term_taxonomy", ["slug"], name: "index_term_taxonomy_on_slug", using: :btree
  add_index "term_taxonomy", ["taxonomy"], name: "index_term_taxonomy_on_taxonomy", using: :btree
  add_index "term_taxonomy", ["term_order"], name: "index_term_taxonomy_on_term_order", using: :btree
  add_index "term_taxonomy", ["user_id"], name: "index_term_taxonomy_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "role",                   default: "client"
    t.string   "email"
    t.string   "slug"
    t.string   "password_digest"
    t.string   "auth_token"
    t.string   "password_reset_token"
    t.integer  "parent_id"
    t.datetime "password_reset_sent_at"
    t.datetime "last_login_at"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "site_id",                default: -1
    t.string   "confirm_email_token"
    t.datetime "confirm_email_sent_at"
    t.boolean  "is_valid_email",         default: true
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["role"], name: "index_users_on_role", using: :btree
  add_index "users", ["site_id"], name: "index_users_on_site_id", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

end
