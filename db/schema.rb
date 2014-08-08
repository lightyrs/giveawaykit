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

ActiveRecord::Schema.define(version: 20140808171517) do

  create_table "active_admin_comments", force: true do |t|
    t.integer  "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_admin_notes_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "audits", force: true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.text     "was"
    t.text     "is"
    t.text     "comment"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "audits", ["auditable_id", "auditable_type"], name: "index_audits_on_auditable_id_and_auditable_type", using: :btree

  create_table "entries", force: true do |t|
    t.string   "email"
    t.boolean  "has_liked",        default: false
    t.string   "name"
    t.string   "fb_url"
    t.datetime "datetime_entered"
    t.integer  "wall_post_count",  default: 0
    t.integer  "request_count",    default: 0
    t.integer  "convert_count",    default: 0
    t.integer  "giveaway_id"
    t.string   "status"
    t.string   "uid"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.text     "ref_ids"
    t.boolean  "is_viral",         default: false
    t.integer  "entry_count",      default: 1
    t.string   "shortlink"
    t.boolean  "has_shared",       default: false
    t.integer  "bonus_entries",    default: 0
  end

  add_index "entries", ["email", "giveaway_id"], name: "index_entries_on_email_and_giveaway_id", unique: true, using: :btree

  create_table "facebook_pages", force: true do |t|
    t.string   "name"
    t.string   "category"
    t.string   "pid"
    t.string   "token"
    t.string   "avatar_square"
    t.string   "avatar_large"
    t.text     "description"
    t.integer  "likes"
    t.string   "url"
    t.boolean  "has_added_app"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "subscription_id"
    t.string   "slug"
    t.integer  "talking_about_count", default: 0
  end

  add_index "facebook_pages", ["pid"], name: "index_facebook_pages_on_pid", unique: true, using: :btree
  add_index "facebook_pages", ["slug"], name: "index_facebook_pages_on_slug", unique: true, using: :btree

  create_table "facebook_pages_users", id: false, force: true do |t|
    t.integer "facebook_page_id", null: false
    t.integer "user_id",          null: false
  end

  add_index "facebook_pages_users", ["facebook_page_id"], name: "index_facebook_pages_users_on_facebook_page_id", using: :btree
  add_index "facebook_pages_users", ["user_id"], name: "index_facebook_pages_users_on_user_id", using: :btree

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", unique: true, using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "giveaways", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "prize"
    t.text     "terms"
    t.text     "preferences"
    t.text     "sticky_post"
    t.boolean  "preview_mode"
    t.string   "giveaway_url"
    t.integer  "facebook_page_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.string   "feed_image_file_name"
    t.string   "feed_image_content_type"
    t.integer  "feed_image_file_size"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "custom_fb_tab_name",      default: "Giveaway"
    t.text     "analytics"
    t.boolean  "active",                  default: false
    t.integer  "uniques",                 default: 0
    t.string   "shortlink"
    t.string   "slug"
    t.boolean  "is_free_trial",           default: false
    t.boolean  "is_hidden",               default: false
    t.integer  "fan_uniques",             default: 0
    t.integer  "non_fan_uniques",         default: 0
    t.integer  "viral_uniques",           default: 0
  end

  add_index "giveaways", ["slug"], name: "index_giveaways_on_slug", unique: true, using: :btree
  add_index "giveaways", ["title", "facebook_page_id"], name: "index_giveaways_on_title_and_facebook_page_id", unique: true, using: :btree

  create_table "identities", force: true do |t|
    t.string   "uid"
    t.string   "provider"
    t.string   "token"
    t.string   "email"
    t.string   "avatar"
    t.string   "profile_url"
    t.string   "location"
    t.integer  "user_id"
    t.integer  "login_count",  default: 0
    t.datetime "logged_in_at"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "identities", ["provider", "user_id"], name: "index_identities_on_provider_and_user_id", unique: true, using: :btree
  add_index "identities", ["uid", "provider"], name: "index_identities_on_uid_and_provider", unique: true, using: :btree
  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "impressions", force: true do |t|
    t.string   "impressionable_type"
    t.integer  "impressionable_id"
    t.integer  "user_id"
    t.string   "controller_name"
    t.string   "action_name"
    t.string   "view_name"
    t.string   "request_hash"
    t.string   "ip_address"
    t.string   "session_hash"
    t.text     "message"
    t.text     "referrer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "impressions", ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index", using: :btree
  add_index "impressions", ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index", using: :btree
  add_index "impressions", ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index", using: :btree
  add_index "impressions", ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index", length: {"impressionable_type"=>nil, "message"=>255, "impressionable_id"=>nil}, using: :btree
  add_index "impressions", ["user_id"], name: "index_impressions_on_user_id", using: :btree

  create_table "likes", force: true do |t|
    t.integer  "entry_id"
    t.integer  "giveaway_id",                 null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.text     "ref_ids"
    t.string   "fb_uid"
    t.boolean  "from_entry",  default: false
    t.boolean  "is_viral",    default: false
  end

  add_index "likes", ["entry_id", "giveaway_id"], name: "index_likes_on_entry_id_and_giveaway_id", unique: true, using: :btree
  add_index "likes", ["entry_id"], name: "index_likes_on_entry_id", using: :btree
  add_index "likes", ["fb_uid", "giveaway_id"], name: "index_likes_on_fb_uid_and_giveaway_id", unique: true, using: :btree
  add_index "likes", ["giveaway_id"], name: "index_likes_on_giveaway_id", using: :btree

  create_table "subscription_plans", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "price_in_cents_per_cycle"
    t.boolean  "is_single_page"
    t.boolean  "is_multi_page"
    t.boolean  "is_onetime"
    t.boolean  "is_monthly"
    t.boolean  "is_yearly"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "subscriptions", force: true do |t|
    t.integer  "subscription_plan_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "activate_next_after"
    t.integer  "next_plan_id"
    t.datetime "current_period_start"
    t.datetime "current_period_end"
    t.text     "next_page_ids"
    t.string   "stripe_subscription_id"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "roles_mask"
    t.string   "stripe_customer_id"
    t.integer  "subscription_id"
    t.boolean  "finished_onboarding", default: false
    t.boolean  "account_current",     default: true
    t.string   "slug"
  end

  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree

end
