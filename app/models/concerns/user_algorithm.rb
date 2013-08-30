module UserAlgorithm
  extend ActiveSupport::Concern

  BOOLEAN_COMPARATORS = %w(healthcare dental vision life_insurance vacation_days equity bonuses retirement special_characteristics)

  TOTAL_POINTS = 20.0

  def score(job_listing)
    ((company_preferred_count(job_listing) + valid_count(job_listing) + benefits_matching_count(job_listing))/TOTAL_POINTS) * 100
  end

  def benefits_matching_count(obj)
    BOOLEAN_COMPARATORS.count do |attr|
      case attr
        when 'vacation_days'
          self.send(attr) ? obj.send(attr) > 0 : true
        when 'equity', 'bonuses'
          self.send(attr) ? obj.send(attr) != 'None' : true
        when 'special_characteristics'
          self.send('open_source') ? obj.send(attr).include?('Open Source Committer') : true
        else
          self.send(attr) ? self.send(attr) == obj.send(attr) : true
      end
    end
  end

  def valid_count(job_listing)
    %w(salary work_hours position vacation_days perks practices availability_to_start location).count do |meth|
      self.send("valid_#{meth}?", job_listing)
    end
  end

  def valid_salary?(job_listing)
    job_listing.salary_range.include?(self.expected_salary)
  end

  def valid_work_hours?(job_listing)
    ((job_listing.estimated_work_hours - 5)..(job_listing.estimated_work_hours + 5)).include?(self.work_hours)
  end

  def valid_position?(job_listing)
    intersected_levels = self.experience_levels & job_listing.experience_levels
    return false unless intersected_levels.present? and (self.experience_levels.length - 1..self.experience_levels.length + 1).include?(intersected_levels.length)
    self.valid_position_type?(job_listing)
  end

  def valid_position_type?(job_listing)
    intersected_positions = self.position_titles & job_listing.position_titles
    intersected_positions.present? and (self.position_titles.length - 1..self.position_titles.length + 1).include?(intersected_positions.length)
  end

  def valid_vacation_days?(job_listing)
    self.vacation_days? ? job_listing.vacation_days > 0 : true
  end

  def valid_perks?(job_listing)
    intersected_perks = self.perks & job_listing.perks
    intersected_perks.present? and (self.perks.length - 1..self.perks.length + 1).include?(intersected_perks.length)
  end

  def valid_practices?(job_listing)
    intersected_practices = self.practices & job_listing.practices
    intersected_practices.present? and (self.practices.length - 1..self.practices.length + 1).include?(intersected_practices.length)
  end

  def valid_availability_to_start?(job_listing)
    (job_listing.hiring_time - 1..job_listing.hiring_time + 1).include?(self.potential_availability)
  end

  def company_preferred_count(job_listing)
    company = job_listing.company
    %w(size industry type).count { |attr| self.send("preferred_company_#{attr}?", company) }
  end

  def preferred_company_size?(company)
    return true if self.company_size.blank? or (self.company_size & Preference::COMPANY_SIZE).length == Preference::COMPANY_SIZE
    self.company_size.any? { |size| Preference::COMPANY_SIZE_RANGES[size].include?(company.num_employees.to_i) }
  end

  def preferred_company_industry?(company)
    return true if self.industries.blank? or company.industry.blank?
    self.industries.include?(company.industry)
  end

  def preferred_company_type?(company)
    return true if self.company_types.blank? or company.size_definition.nil?
    self.company_types.include?(company.size_definition)
  end

  def valid_location?(job_listing)
    self.willing_to_relocate or self.locations.blank? or self.locations.include?(job_listing.location)
  end
end
