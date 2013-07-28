class JobListing < ActiveRecord::Base
  attr_accessible :job_title, :job_description, :experience_level, :estimated_work_hours, :salary_range_low,
                  :salary_range_high, :vacation_days, :healthcare, :equity, :bonuses, :retirement,
                  :perks, :fulltime, :remote, :hiring_time, :tech_stack_id, :location, :position_type,
                  :special_characteristics, :company_id, :active, :sponsorship_available, :practices,
                  :acceptable_languages, :dental, :vision, :life_insurance

  belongs_to :company
  validate :salary_range_check

  HASHABLE_PARAMS = ['practices', 'perks', 'experience_level', 'special_characteristics', 'acceptable_languages', 'position_type']

  def salary_range
    (self.salary_range_low..self.salary_range_high)
  end

  def salary_range_check
    errors.add(:salary_range, "Invalid salary range") unless salary_range_high >= salary_range_low
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
