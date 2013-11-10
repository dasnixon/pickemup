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
#  tech_stack_id           :uuid
#

class JobListing < ActiveRecord::Base
  include PreferenceConstants
  include PreferencesHelper
  include PickemupAPI

  HASHABLE_PARAMS       = %w(practices perks experience_levels special_characteristics acceptable_languages position_titles locations)
  LISTINGS_ATTR_REGEX   = /^id$|job_title|languages|company_id|salary|locations/
  COMPANY_ATTR_REGEX    = /name|website|industry/
  USER_ATTR_REGEX       = /^id$|name|location/
  PREFERENCE_ATTR_REGEX = /salary|skills|locations|expected_salary|valid_us_worker|match_threshold/
  EQUITY_SELECTIONS     = ['None', 'Less than 1%', '1% - 5%', 'Greater than 5%']
  BONUS_SELECTIONS      = ['None', '1-10% of base salary', 'Greater than 10% of base salary', 'Something else']

  belongs_to :company
  has_many :conversations
  belongs_to :tech_stack

  validates :salary_range_high, :salary_range_low, presence: true, numericality: { only_integer: true }
  validates :job_description, presence: true, length: { maximum: 3000 }
  validates :synopsis, length: { maximum: 300 }
  validates :vacation_days, numericality: { only_integer: true }, inclusion: { in: 0..200, message: 'Are they ever going to work?' }
  validates :estimated_work_hours, numericality: true, inclusion: { in: 0..168, message: 'Are you trying to hire a machine?' }
  validates :hiring_time, numericality: true, inclusion: { in: 0..52, message: 'You may want them to start this year.' }
  validates :equity, inclusion: { in: EQUITY_SELECTIONS }, allow_nil: true
  validates :bonuses, inclusion: { in: BONUS_SELECTIONS }, allow_nil: true
  validate :salary_range_check, if: Proc.new { |j| j.salary_range_low.present? and j.salary_range_high.present? }

  scope :active, -> { where(active: true) }

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
        preference = user.preference
        next unless preference.preference_percentage_filled >= 60
        if user.description.present?
          html_string = TruncateHtml::HtmlString.new(user.description)
          truncated_description = TruncateHtml::HtmlTruncator.new(html_string, length: 360, omission: '...').truncate
        end
        user_attrs = user.attributes.keep_if { |k,v| k =~ USER_ATTR_REGEX }.merge('profile_image' => user.profile_image.url(:medium), 'description' => truncated_description)
        preference_attrs = user.preference.attributes.keep_if { |k,v| k =~ PREFERENCE_ATTR_REGEX }.merge('score' => preference.score(self.id)['score'].to_i)
        matches << user_attrs.merge(preference_attrs)
      end
    end
    matches.compact.sort_by { |match| match['score'] }.reverse!
    matches
  end

  def search_attributes(user)
    return nil if user.already_has_applied?(self.id)
    preference, company = user.preference, self.company
    return nil unless preference.preference_percentage_filled >= 60
    text_to_truncate = self.synopsis.present? ? self.synopsis : self.job_description
    if text_to_truncate.present?
      html_string = TruncateHtml::HtmlString.new(text_to_truncate)
      truncated_description = TruncateHtml::HtmlTruncator.new(html_string, length: 360, omission: '...').truncate
    end
    listing_attrs = self.attributes.keep_if { |k,v| k =~ LISTINGS_ATTR_REGEX }.merge('score' => self.score(preference.id)['score'].to_i, 'details' => truncated_description)
    company_attrs = company.attributes.keep_if { |k,v| k =~ COMPANY_ATTR_REGEX }.merge('logo' => company.logo.url(:medium))
    company_attrs.merge(listing_attrs)
  end
end
