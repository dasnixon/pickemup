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

ActiveRecord::Schema.define(version: 20130721005835) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "companies", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_salt"
    t.string   "password_hash"
    t.string   "description"
    t.string   "website"
    t.string   "industry"
    t.string   "num_employees"
    t.boolean  "public",        default: false
    t.date     "founded"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conversations", force: true do |t|
    t.string   "subject",    default: ""
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "educations", force: true do |t|
    t.text     "activities"
    t.string   "degree"
    t.string   "field_of_study"
    t.text     "notes"
    t.string   "school_name"
    t.string   "start_year"
    t.string   "end_year"
    t.string   "education_key"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "educations", ["education_key"], name: "index_educations_on_education_key", using: :btree

  create_table "github_accounts", force: true do |t|
    t.string   "nickname"
    t.string   "profile_image"
    t.boolean  "hireable"
    t.text     "bio"
    t.integer  "public_repos_count"
    t.integer  "number_followers"
    t.integer  "number_following"
    t.integer  "number_gists"
    t.string   "token"
    t.string   "github_account_key"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "github_accounts", ["github_account_key"], name: "index_github_accounts_on_github_account_key", using: :btree

  create_table "linkedins", force: true do |t|
    t.string   "token"
    t.string   "headline"
    t.string   "industry"
    t.string   "uid"
    t.string   "profile_url"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "linkedins", ["uid"], name: "index_linkedins_on_uid", using: :btree

  create_table "notifications", force: true do |t|
    t.string   "type"
    t.text     "body"
    t.string   "subject",              default: ""
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "conversation_id"
    t.boolean  "draft",                default: false
    t.datetime "updated_at",                           null: false
    t.datetime "created_at",                           null: false
    t.integer  "notified_object_id"
    t.string   "notified_object_type"
    t.string   "notification_code"
    t.string   "attachment"
    t.boolean  "global",               default: false
    t.datetime "expires"
  end

  add_index "notifications", ["conversation_id"], name: "index_notifications_on_conversation_id", using: :btree

  create_table "organizations", force: true do |t|
    t.string   "name"
    t.string   "avatar_url"
    t.string   "url"
    t.string   "organization_key"
    t.string   "location"
    t.integer  "number_followers"
    t.integer  "number_following"
    t.string   "blog"
    t.integer  "public_repos_count"
    t.string   "company_type"
    t.integer  "github_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizations", ["organization_key"], name: "index_organizations_on_organization_key", using: :btree

  create_table "positions", force: true do |t|
    t.string   "industry"
    t.string   "company_type"
    t.string   "name"
    t.string   "size"
    t.string   "company_key"
    t.boolean  "is_current"
    t.string   "title"
    t.text     "summary"
    t.string   "start_year"
    t.string   "start_month"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "positions", ["company_key"], name: "index_positions_on_company_key", using: :btree

  create_table "preferences", force: true do |t|
    t.boolean  "healthcare"
    t.boolean  "dentalcare"
    t.boolean  "visioncare"
    t.boolean  "life_insurance"
    t.boolean  "paid_vacation"
    t.boolean  "equity"
    t.boolean  "bonuses"
    t.boolean  "retirement"
    t.boolean  "fulltime"
    t.integer  "remote"
    t.boolean  "open_source"
    t.integer  "expected_salary"
    t.integer  "potential_availability"
    t.integer  "company_size"
    t.integer  "work_hours"
    t.json     "skills"
    t.json     "locations"
    t.json     "industries"
    t.json     "positions"
    t.json     "settings"
    t.json     "dress_codes"
    t.json     "company_types"
    t.json     "perks"
    t.json     "practices"
    t.json     "levels"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", force: true do |t|
    t.integer  "number_connections"
    t.integer  "number_recommenders"
    t.text     "summary"
    t.string   "skills",              default: [], array: true
    t.integer  "linkedin_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "receipts", force: true do |t|
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.integer  "notification_id",                            null: false
    t.boolean  "is_read",                    default: false
    t.boolean  "trashed",                    default: false
    t.boolean  "deleted",                    default: false
    t.string   "mailbox_type",    limit: 25
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "receipts", ["notification_id"], name: "index_receipts_on_notification_id", using: :btree

  create_table "repos", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "private"
    t.string   "url"
    t.string   "language"
    t.integer  "number_forks"
    t.integer  "number_watchers"
    t.integer  "size"
    t.integer  "open_issues"
    t.datetime "started"
    t.datetime "last_updated"
    t.string   "repo_key"
    t.integer  "github_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "repos", ["repo_key"], name: "index_repos_on_repo_key", using: :btree

  create_table "stackexchanges", force: true do |t|
    t.string   "token"
    t.string   "uid"
    t.string   "profile_url"
    t.integer  "reputation"
    t.integer  "age"
    t.string   "profile_image"
    t.hstore   "badges"
    t.string   "display_name"
    t.string   "nickname"
    t.string   "stackexchange_key"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stackexchanges", ["stackexchange_key"], name: "index_stackexchanges_on_stackexchange_key", using: :btree

  create_table "subscriptions", force: true do |t|
    t.integer  "plan"
    t.integer  "company_id",                            null: false
    t.string   "stripe_customer_token"
    t.string   "stripe_card_token"
    t.boolean  "active",                default: false
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "uid"
    t.string   "email"
    t.string   "name"
    t.string   "location"
    t.string   "blog"
    t.string   "current_company"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", using: :btree

  add_foreign_key "notifications", "conversations", :name => "notifications_on_conversation_id"

  add_foreign_key "receipts", "notifications", :name => "receipts_on_notification_id"

end
