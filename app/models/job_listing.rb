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
  attr_accessible :job_title, :job_description, :experience_level, :estimated_work_hours, :salary_range_low,
                  :salary_range_high, :vacation_days, :healthcare, :equity, :bonuses, :retirement,
                  :perks, :fulltime, :remote, :hiring_time, :tech_stack_id, :location, :position_type,
                  :special_characteristics, :company_id, :active, :sponsorship_available, :practices,
                  :acceptable_languages, :dental, :vision, :life_insurance

  belongs_to :company
  has_many :conversations
  validate :salary_range_check
  validates :job_description, presence: true

  HASHABLE_PARAMS = ['practices', 'perks', 'experience_level', 'special_characteristics', 'acceptable_languages', 'position_type']

  def salary_range
    (self.salary_range_low..self.salary_range_high)
  end

  #validation to check that the salary ranges are correct
  def salary_range_check
    errors.add(:salary_range, "Invalid salary range") if salary_range_high.nil? || salary_range_low.nil? || salary_range_high <= salary_range_low
  end

  def unhash_all_params(job_listing_params)
    HASHABLE_PARAMS.each do |param|
      all_params = job_listing_params[param]
      if all_params
        new_params = all_params.select { |attr| attr["checked"] == true }.map { |attr| attr["name"] }
        eval("self.#{param} = #{new_params}")
        job_listing_params.delete(param)
      end
    end
    job_listing_params
  end

  def create_param_hash(attributes, check_value = false)
    attributes.map { |attr| {name: attr, checked: check_value} }
  end

  def populate_all_params
    HASHABLE_PARAMS.each do |param|
      stored_params = self.try(param)
      checked = stored_params ? stored_params : []
      unchecked_defaults = ("PreferenceConstants::#{param.upcase}".constantize - checked)
      params_to_render = create_param_hash(checked, true) + create_param_hash(unchecked_defaults)
      eval("self.#{param} = #{params_to_render}")
    end
  end
end
