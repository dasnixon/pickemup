# == Schema Information
#
# Table name: job_listings
#
#  id                      :uuid             not null, primary key
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
#  experience_levels       :string(255)      default([])
#  perks                   :string(255)      default([])
#  position_titles         :string(255)      default([])
#  created_at              :datetime
#  updated_at              :datetime
#  company_id              :uuid
#  locations               :string(255)      default([])
#  synopsis                :text
#

class JobListing < ActiveRecord::Base
  include PreferenceConstants
  include PreferencesHelper
  include PickemupAPI

  HASHABLE_PARAMS = %w(practices perks experience_levels special_characteristics acceptable_languages position_titles locations)

  belongs_to :company
  has_many :conversations
  belongs_to :tech_stack

  validates :salary_range_high, :salary_range_low, presence: true, numericality: { only_integer: true }
  validates :job_description, presence: true
  validates :synopsis, length: { maximum: 300 }
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

  def api_attributes
    attrs = self.attributes
    attrs.merge!(job_listing_id: attrs.delete("id"), expiration_time: self.company.subscription.expiration_time, skills: skills, locations: self.locations)
  end

  def skills
    stack_skills = []
    self.try(:tech_stack).attributes.each { |key, val| stack_skills += val if val.class.name == "Array" } if self.try(:tech_stack)
    self.acceptable_languages + stack_skills
  end

  def live?
    return false if self.company.subscription.expired?
    self.active
  end

  def score(preference_id)
    score = $scores.get("score.#{self.id}.#{preference_id}")
    score ? JSON(score) : {}
  end

  def match_users
    matches, company = [], self.company
    User.all.find_in_batches do |batched_users|
      batched_users.each do |user|
        next if matches.length >= 25 or company.already_has_conversation_over?(self.id, user)
        user_attrs = user.attributes.keep_if { |k,v| k =~ /^id$|name|description|location/ }.merge('profile_image' => user.profile_image.url(:medium))
        preference_attrs = user.preference.attributes.keep_if { |k,v| k =~ /salary|skills|locations|expected_salary/ }.merge('score' => user.preference.score(self.id)['score'].to_i)
        matches << user_attrs.merge(preference_attrs)
      end
    end
    matches.sort_by { |match| match['score'] }.reverse!
    matches
  end

  def search_attributes(preference_id, user)
    return nil if user.already_has_applied?(self.id)
    listing_attrs = self.attributes.keep_if { |k,v| k =~ /^id$|job_title|synopsis|languages|company_id|salary|description|locations/ }.merge('score' => self.score(preference_id)['score'].to_i)
    comp = self.company
    company_attrs = comp.attributes.keep_if { |k,v| k =~ /name|website|industry/ }.merge('logo' => comp.logo.url(:medium))
    company_attrs.merge(listing_attrs)
  end
end
