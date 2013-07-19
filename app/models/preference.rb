# == Schema Information
#
# Table name: preferences
#
#  id                     :integer          not null, primary key
#  healthcare             :boolean
#  dentalcare             :boolean
#  visioncare             :boolean
#  life_insurance         :boolean
#  paid_vacation          :boolean
#  equity                 :boolean
#  bonuses                :boolean
#  retirement             :boolean
#  fulltime               :boolean
#  remote                 :integer
#  open_source            :boolean
#  expected_salary        :integer
#  potential_availability :integer
#  company_size           :integer
#  work_hours             :integer
#  skills                 :hstore           default({})
#  locations              :string(255)      default([])
#  industries             :string(255)      default([])
#  positions              :string(255)      default([])
#  settings               :string(255)      default([])
#  dress_codes            :string(255)      default([])
#  company_types          :string(255)      default([])
#  perks                  :string(255)      default([])
#  practices              :string(255)      default([])
#  user_id                :integer
#  created_at             :datetime
#  updated_at             :datetime
#

class Preference < ActiveRecord::Base
  include PreferenceConstants

  belongs_to :user

  validates :expected_salary, numericality: true, inclusion: { in: 1..20000000 }, allow_blank: true
  validates :work_hours, numericality: true, inclusion: { in: 1..168 }, allow_blank: true
  validates :company_size, :potential_availability, numericality: true, inclusion: { in: 0..4 }, allow_blank: true
  validates :remote, numericality: true, inclusion: { in: 0..2 }, allow_blank: true

  def remote_to_string
    REMOTE[self.remote]
  end

  def company_size_to_string
    COMPANY_SIZE[self.company_size]
  end

  def set_skills(profile_skills)
    new_skills = {}
    profile_skills.each { |skill| new_skills[skill] = "false" unless self.skills.has_key?(skill) }
    self.skills = self.skills.merge(new_skills)
    self.save!
  end
end
