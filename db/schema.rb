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

ActiveRecord::Schema.define(version: 20130626065929) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "users", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "email"
    t.string   "nickname"
    t.string   "name"
    t.string   "github_profile_image"
    t.string   "location"
    t.string   "blog"
    t.string   "current_company"
    t.boolean  "hireable"
    t.text     "description"
    t.text     "github_bio"
    t.integer  "public_repos_count"
    t.integer  "github_number_followers"
    t.integer  "github_number_following"
    t.integer  "github_number_public_gists"
    t.string   "github_token"
    t.string   "linkedin_token"
    t.string   "headline"
    t.string   "industry"
    t.string   "linkedin_uid"
    t.string   "linkedin_profile_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
