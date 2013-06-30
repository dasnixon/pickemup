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

ActiveRecord::Schema.define(version: 20130630094116) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

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
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "profiles", force: true do |t|
    t.integer  "number_connections"
    t.integer  "number_recommenders"
    t.text     "summary"
    t.string   "skills",              array: true
    t.integer  "linkedin_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

end
