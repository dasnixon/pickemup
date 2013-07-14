# == Schema Information
#
# Table name: preferences
#
#  id                     :integer          not null, primary key
#  expected_salary        :integer
#  vacation_days          :integer
#  healthcare             :boolean
#  equity                 :boolean
#  bonuses                :boolean
#  retirement             :boolean
#  perks                  :hstore           default({})
#  practices              :hstore           default({})
#  fulltime               :boolean
#  remote                 :boolean
#  potential_availability :integer
#  open_source            :boolean
#  company_size           :int8range
#  skills                 :string(255)      default([])
#  locations              :string(255)      default([])
#  industries             :string(255)      default([])
#  positions              :string(255)      default([])
#  settings               :string(255)      default([])
#  dress_codes            :string(255)      default([])
#  company_types          :string(255)      default([])
#  user_id                :integer
#  created_at             :datetime
#  updated_at             :datetime
#

class Preference < ActiveRecord::Base
  belongs_to :user
end
