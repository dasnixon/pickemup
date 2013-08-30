class Algorithm
  attr_accessor :preference, :job_listing, :user, :company, :score

  BOOLEAN_COMPARATORS = %w(healthcare dental vision life_insurance vacation_days equity bonuses retirement special_characteristics)
  TOTAL_POINTS = 20.0

  def initialize(preference, job_listing, user: nil, company: nil, run_score: true)
    raise "Unable to score with an invalid preference or job listing" if preference.blank? or job_listing.blank?
    self.preference, self.job_listing = preference, job_listing
    self.company, self.user = (company || job_listing.company), user
    self.score = get_score if run_score
  end

  def get_score
    ((company_preferred_count + valid_count + benefits_matching_count)/TOTAL_POINTS) * 100
  end

  def benefits_matching_count
    BOOLEAN_COMPARATORS.count do |attr|
      case attr
        when 'vacation_days'
          self.preference.send(attr) ? self.job_listing.send(attr) > 0 : true
        when 'equity', 'bonuses'
          self.preference.send(attr) ? self.job_listing.send(attr) != 'None' : true
        when 'special_characteristics'
          self.preference.send('open_source') ? self.job_listing.send(attr).include?('Open Source Committer') : true
        else
          self.preference.send(attr) ? self.preference.send(attr) == self.job_listing.send(attr) : true
      end
    end
  end

  def valid_count
    %w(salary work_hours position vacation_days perks practices availability_to_start location).count do |meth|
      self.send("valid_#{meth}?")
    end
  end

  def valid_salary?
    self.job_listing.salary_range.include?(self.preference.expected_salary)
  end

  def valid_work_hours?
    ((self.job_listing.estimated_work_hours - 5)..(self.job_listing.estimated_work_hours + 5)).include?(self.preference.work_hours)
  end

  def valid_position?
    intersected_levels = self.preference.experience_levels & self.job_listing.experience_levels
    return false unless intersected_levels.present? and (self.preference.experience_levels.length - 1..self.preference.experience_levels.length + 1).include?(intersected_levels.length)
    self.valid_position_type?
  end

  def valid_position_type?
    intersected_positions = self.preference.position_titles & self.job_listing.position_titles
    intersected_positions.present? and (self.preference.position_titles.length - 1..self.preference.position_titles.length + 1).include?(intersected_positions.length)
  end

  def valid_vacation_days?
    self.preference.vacation_days? ? self.job_listing.vacation_days > 0 : true
  end

  def valid_perks?
    intersected_perks = self.preference.perks & self.job_listing.perks
    intersected_perks.present? and (self.preference.perks.length - 1..self.preference.perks.length + 1).include?(intersected_perks.length)
  end

  def valid_practices?
    intersected_practices = self.preference.practices & self.job_listing.practices
    intersected_practices.present? and (self.preference.practices.length - 1..self.preference.practices.length + 1).include?(intersected_practices.length)
  end

  def valid_availability_to_start?
    (self.job_listing.hiring_time - 1..self.job_listing.hiring_time + 1).include?(self.preference.potential_availability)
  end

  def valid_location?
    self.preference.willing_to_relocate or self.preference.locations.blank? or self.preference.locations.include?(self.job_listing.location)
  end

  def company_preferred_count
    %w(size industry type).count { |attr| self.send("preferred_company_#{attr}?") }
  end

  def preferred_company_size?
    return true if self.preference.company_size.blank? or (self.preference.company_size & Preference::COMPANY_SIZE).length == Preference::COMPANY_SIZE
    self.preference.company_size.any? { |size| Preference::COMPANY_SIZE_RANGES[size].include?(self.company.num_employees.to_i) }
  end

  def preferred_company_industry?
    return true if self.preference.industries.blank? or self.company.industry.blank?
    self.preference.industries.include?(company.industry)
  end

  def preferred_company_type?
    return true if self.preference.company_types.blank? or self.company.size_definition.nil?
    self.preference.company_types.include?(self.company.size_definition)
  end
end
