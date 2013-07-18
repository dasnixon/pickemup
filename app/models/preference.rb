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
#  skills                 :string(255)      default([])
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
  belongs_to :user

  validates :expected_salary, numericality: true, inclusion: { in: 1..20000000 }, allow_blank: true
  validates :work_hours, numericality: true, inclusion: { in: 1..168 }, allow_blank: true
  validates :company_size, :potential_availability, numericality: true, inclusion: { in: 0..4 }, allow_blank: true
  validates :remote, numericality: true, inclusion: { in: 0..2 }, allow_blank: true

  REMOTE = {0 => "No", 1 => "Yes", 2 => "I'm open to remote work"}
  COMPANY_SIZE = {0 => "1-10 Employees", 1 => "11-50 Employees", 2 => "51-200 Employees", 3 => "201-500 Employees", 4 => "501+ Employees"}

  def remote_to_string
    REMOTE[self.remote]
  end

  def company_size_to_string
    COMPANY_SIZE[self.company_size]
  end
end
