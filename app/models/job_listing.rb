# == Schema Information
#
# Table name: job_listings
#
#  id                      :integer          not null, primary key
#  job_title               :string(255)
#  job_description         :text
#  salary_range_high       :integer
#  salary_range_low        :integer
#  vacation_days           :integer
#  equity                  :string(255)
#  bonuses                 :string(255)
#  fulltime                :boolean          default(TRUE)
#  remote                  :boolean
#  hiring_time             :integer
#  tech_stack_id           :integer
#  location                :string(255)
#  active                  :boolean          default(FALSE)
#  sponsorship_available   :boolean          default(FALSE)
#  healthcare              :boolean          default(FALSE)
#  dental                  :boolean          default(FALSE)
#  vision                  :boolean          default(FALSE)
#  life_insurance          :boolean          default(FALSE)
#  retirement              :boolean          default(FALSE)
#  estimated_work_hours    :integer
#  practices               :string(255)      default([])
#  acceptable_languages    :string(255)      default([])
#  special_characteristics :string(255)      default([])
#  experience_level        :string(255)      default([])
#  perks                   :string(255)      default([])
#  position_type           :string(255)      default([])
#  created_at              :datetime
#  updated_at              :datetime
#  company_id              :integer
#

class JobListing < ActiveRecord::Base
  include PreferenceConstants
  include PreferencesHelper

  HASHABLE_PARAMS = ['practices', 'perks', 'experience_level', 'special_characteristics', 'acceptable_languages', 'position_type']

  attr_accessible :job_title, :job_description, :experience_level, :estimated_work_hours, :salary_range_low,
                  :salary_range_high, :vacation_days, :healthcare, :equity, :bonuses, :retirement,
                  :perks, :fulltime, :remote, :hiring_time, :tech_stack_id, :location, :position_type,
                  :special_characteristics, :company_id, :active, :sponsorship_available, :practices,
                  :acceptable_languages, :dental, :vision, :life_insurance

  belongs_to :company
  has_many :conversations

  validates :salary_range_high, :salary_range_low, presence: true, numericality: { only_integer: true }
  validates :job_description, presence: true
  validate :salary_range_check, if: Proc.new { |j| j.salary_range_low.present? and j.salary_range_high.present? }

  def salary_range
    (self.salary_range_low..self.salary_range_high)
  end

  #validation to check that the salary ranges are correct
  def salary_range_check
    errors.add(:salary_range, 'Invalid salary range') if salary_range_high <= salary_range_low
  end

  def attribute_default_values(attr)
    self.class.const_get(attr.upcase)
  end

  def toggle_active
    self.update(active: !self.active)
  end
end
