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

ActiveRecord::Schema.define(version: 20140109051301) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "uuid-ossp"

  create_table "admins", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "email"
    t.string   "name"
    t.string   "password_salt"
    t.string   "password_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "code_snippet_files", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "name"
    t.text     "content"
    t.integer  "size"
    t.string   "url"
    t.uuid     "code_snippet_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "code_snippets", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.text     "description"
    t.string   "url"
    t.string   "gist_key"
    t.boolean  "public"
    t.integer  "comments_count"
    t.string   "comments_url"
    t.datetime "gist_created_at"
    t.uuid     "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_salt"
    t.string   "password_hash"
    t.text     "description"
    t.string   "website"
    t.string   "industry"
    t.string   "num_employees"
    t.boolean  "public",             default: false
    t.date     "founded"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "acquired_by"
    t.string   "tags",               default: [],    array: true
    t.string   "total_money_raised"
    t.string   "competitors",        default: [],    array: true
    t.string   "logo"
    t.boolean  "verified",           default: false
    t.datetime "last_sign_in_at"
    t.datetime "current_sign_in_at"
    t.inet     "last_sign_in_ip"
    t.inet     "current_sign_in_ip"
    t.integer  "sign_in_count"
    t.string   "size_definition"
    t.boolean  "active",             default: true
  end

  add_index "companies", ["email"], name: "index_companies_on_email", unique: true, using: :btree
  add_index "companies", ["name"], name: "index_companies_on_name", unique: true, using: :btree

  create_table "conversations", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "subject",        default: ""
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.uuid     "job_listing_id",              null: false
  end

  create_table "educations", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.text     "activities"
    t.string   "degree"
    t.string   "field_of_study"
    t.text     "notes"
    t.string   "school_name"
    t.string   "start_year"
    t.string   "end_year"
    t.string   "education_key"
    t.uuid     "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "educations", ["education_key"], name: "index_educations_on_education_key", using: :btree
  add_index "educations", ["profile_id"], name: "index_educations_on_profile_id", using: :btree

  create_table "github_accounts", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "nickname"
    t.boolean  "hireable"
    t.text     "bio"
    t.integer  "public_repos_count"
    t.integer  "number_followers"
    t.integer  "number_following"
    t.integer  "number_gists"
    t.string   "blog"
    t.string   "token"
    t.string   "github_account_key"
    t.string   "uid"
    t.uuid     "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "skills",             default: [], array: true
  end

  add_index "github_accounts", ["github_account_key"], name: "index_github_accounts_on_github_account_key", using: :btree
  add_index "github_accounts", ["uid"], name: "index_github_accounts_on_uid", using: :btree
  add_index "github_accounts", ["user_id"], name: "index_github_accounts_on_user_id", unique: true, using: :btree

  create_table "interviews", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "status",         default: "pending"
    t.boolean  "hireable"
    t.datetime "request_date"
    t.uuid     "job_listing_id"
    t.uuid     "company_id"
    t.uuid     "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "duration"
    t.text     "description"
    t.string   "location"
  end

  add_index "interviews", ["user_id", "company_id", "job_listing_id"], name: "index_interviews_on_user_id_and_company_id_and_job_listing_id", unique: true, using: :btree

  create_table "job_listings", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "job_title"
    t.text     "job_description"
    t.integer  "salary_range_high"
    t.integer  "salary_range_low"
    t.integer  "vacation_days"
    t.string   "equity"
    t.string   "bonuses"
    t.boolean  "fulltime",                default: true
    t.boolean  "remote"
    t.integer  "hiring_time"
    t.boolean  "active",                  default: false
    t.boolean  "sponsorship_available",   default: false
    t.boolean  "healthcare",              default: false
    t.boolean  "dental",                  default: false
    t.boolean  "vision",                  default: false
    t.boolean  "life_insurance",          default: false
    t.boolean  "retirement",              default: false
    t.integer  "estimated_work_hours"
    t.string   "practices",               default: [],    array: true
    t.string   "acceptable_languages",    default: [],    array: true
    t.string   "special_characteristics", default: [],    array: true
    t.string   "experience_levels",       default: [],    array: true
    t.string   "perks",                   default: [],    array: true
    t.string   "position_titles",         default: [],    array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "company_id"
    t.string   "locations",               default: [],    array: true
    t.text     "synopsis"
    t.uuid     "tech_stack_id"
    t.integer  "match_threshold",         default: 0
  end

  add_index "job_listings", ["company_id"], name: "index_job_listings_on_company_id", using: :btree
  add_index "job_listings", ["tech_stack_id"], name: "index_job_listings_on_tech_stack_id", using: :btree

  create_table "linkedins", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "token"
    t.string   "headline"
    t.string   "industry"
    t.string   "uid"
    t.string   "profile_url"
    t.uuid     "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "linkedins", ["uid"], name: "index_linkedins_on_uid", using: :btree
  add_index "linkedins", ["user_id"], name: "index_linkedins_on_user_id", unique: true, using: :btree

  create_table "notifications", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "type"
    t.text     "body"
    t.string   "subject",              default: ""
    t.uuid     "sender_id"
    t.string   "sender_type"
    t.uuid     "conversation_id"
    t.boolean  "draft",                default: false
    t.datetime "updated_at",                           null: false
    t.datetime "created_at",                           null: false
    t.uuid     "notified_object_id"
    t.uuid     "notified_object_type"
    t.string   "notification_code"
    t.string   "attachment"
    t.boolean  "global",               default: false
    t.datetime "expires"
  end

  add_index "notifications", ["conversation_id"], name: "index_notifications_on_conversation_id", using: :btree

  create_table "organizations", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "name"
    t.string   "logo"
    t.string   "url"
    t.string   "organization_key"
    t.string   "location"
    t.integer  "number_followers"
    t.integer  "number_following"
    t.string   "blog"
    t.integer  "public_repos_count"
    t.string   "company_type"
    t.uuid     "github_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizations", ["github_account_id"], name: "index_organizations_on_github_account_id", using: :btree
  add_index "organizations", ["organization_key"], name: "index_organizations_on_organization_key", using: :btree

  create_table "positions", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "industry"
    t.string   "company_type"
    t.string   "name"
    t.string   "size"
    t.string   "position_key"
    t.boolean  "is_current"
    t.string   "title"
    t.text     "summary"
    t.string   "start_year"
    t.string   "start_month"
    t.uuid     "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "end_year"
    t.string   "end_month"
  end

  add_index "positions", ["position_key"], name: "index_positions_on_position_key", using: :btree
  add_index "positions", ["profile_id"], name: "index_positions_on_profile_id", using: :btree

  create_table "preferences", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.boolean  "healthcare",             default: false
    t.boolean  "dental",                 default: false
    t.boolean  "vision",                 default: false
    t.boolean  "life_insurance",         default: false
    t.boolean  "vacation_days",          default: false
    t.boolean  "equity",                 default: false
    t.boolean  "bonuses",                default: false
    t.boolean  "retirement",             default: false
    t.boolean  "fulltime",               default: true
    t.boolean  "valid_us_worker",        default: false
    t.boolean  "open_source",            default: false
    t.boolean  "remote",                 default: false
    t.integer  "expected_salary",        default: 0
    t.integer  "potential_availability", default: 0
    t.integer  "work_hours",             default: 0
    t.string   "company_size",           default: [],    array: true
    t.string   "skills",                 default: [],    array: true
    t.string   "locations",              default: [],    array: true
    t.string   "industries",             default: [],    array: true
    t.string   "position_titles",        default: [],    array: true
    t.string   "company_types",          default: [],    array: true
    t.string   "perks",                  default: [],    array: true
    t.string   "practices",              default: [],    array: true
    t.string   "experience_levels",      default: [],    array: true
    t.uuid     "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "willing_to_relocate",    default: false
    t.integer  "match_threshold",        default: 0
  end

  add_index "preferences", ["user_id"], name: "index_preferences_on_user_id", unique: true, using: :btree

  create_table "profiles", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.integer  "number_connections"
    t.integer  "number_recommenders"
    t.text     "summary"
    t.string   "skills",              default: [], array: true
    t.uuid     "linkedin_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["linkedin_id"], name: "index_profiles_on_linkedin_id", unique: true, using: :btree

  create_table "receipts", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "receiver_id"
    t.string   "receiver_type"
    t.uuid     "notification_id",                            null: false
    t.boolean  "is_read",                    default: false
    t.boolean  "trashed",                    default: false
    t.boolean  "deleted",                    default: false
    t.string   "mailbox_type",    limit: 25
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "receipts", ["notification_id"], name: "index_receipts_on_notification_id", using: :btree

  create_table "repos", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
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
    t.uuid     "github_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "repos", ["github_account_id"], name: "index_repos_on_github_account_id", using: :btree
  add_index "repos", ["repo_key"], name: "index_repos_on_repo_key", using: :btree

  create_table "stackexchanges", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "token"
    t.string   "uid"
    t.string   "profile_url"
    t.integer  "reputation"
    t.integer  "age"
    t.hstore   "badges"
    t.string   "display_name"
    t.string   "nickname"
    t.string   "stackexchange_key"
    t.uuid     "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stackexchanges", ["stackexchange_key"], name: "index_stackexchanges_on_stackexchange_key", using: :btree
  add_index "stackexchanges", ["user_id"], name: "index_stackexchanges_on_user_id", unique: true, using: :btree

  create_table "subscriptions", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.integer  "plan"
    t.uuid     "company_id",                            null: false
    t.string   "stripe_customer_token"
    t.string   "stripe_card_token"
    t.boolean  "active",                default: false
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
  end

  add_index "subscriptions", ["company_id"], name: "index_subscriptions_on_company_id", unique: true, using: :btree

  create_table "tech_stacks", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "company_id"
    t.string   "name"
    t.string   "back_end_languages",   default: [], array: true
    t.string   "front_end_languages",  default: [], array: true
    t.string   "frameworks",           default: [], array: true
    t.string   "dev_ops_tools",        default: [], array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nosql_databases",      default: [], array: true
    t.string   "relational_databases", default: [], array: true
  end

  add_index "tech_stacks", ["company_id"], name: "index_tech_stacks_on_company_id", using: :btree

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "github_uid"
    t.string   "linkedin_uid"
    t.string   "email"
    t.string   "name"
    t.string   "location"
    t.string   "profile_image"
    t.string   "main_provider"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "stackexchange_synced",   default: false
    t.datetime "last_sign_in_at"
    t.datetime "current_sign_in_at"
    t.inet     "last_sign_in_ip"
    t.inet     "current_sign_in_ip"
    t.integer  "sign_in_count"
    t.boolean  "manually_setup_profile", default: false
    t.boolean  "active",                 default: true
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["github_uid"], name: "index_users_on_github_uid", using: :btree
  add_index "users", ["linkedin_uid"], name: "index_users_on_linkedin_uid", using: :btree

  add_foreign_key "notifications", "conversations", name: "notifications_on_conversation_id"

  add_foreign_key "receipts", "notifications", name: "receipts_on_notification_id"

end
