module UserAlgorithm
  extend ActiveSupport::Concern

  BOOLEAN_COMPARATORS = %w(healthcare dental vision life_insurance paid_vacation equity bonuses retirement special_characteristics)

  def benefits_matching_count(obj)
    BOOLEAN_COMPARATORS.count do |attr|
      case attr
        when 'dental'
          self.send('dentalcare') ? self.send('dentalcare') == obj.send(attr) : true
        when 'vision'
          self.send('visioncare') ? self.send('visioncare') == obj.send(attr) : true
        when 'paid_vacation'
          self.send('paid_vacation') ? obj.send('vacation_days') > 0 : true
        when 'equity', 'bonuses'
          self.send(attr) ? obj.send(attr) != 'None' : true
        when 'special_characteristics'
          self.send('open_source') ? obj.send(attr).include?('Open Source Committer') : true
        else
          self.send(attr) ? self.send(attr) == obj.send(attr) : true
      end
    end
  end

  #check if the user's expected salary is within the range of the job listing's
  #specified salary
  def valid_salary?(job_listing)
    job_listing.salary_range.include?(self.expected_salary)
  end

  def valid_work_hours?(job_listing)
    ((job_listing.estimated_work_hours - 5)..(job_listing.estimated_work_hours + 5)).include?(self.work_hours)
  end

  def valid_position?(job_listing)
    intersected_levels = self.levels & job_listing.experience_level
    return false unless intersected_levels.present? && (self.levels.length - 1..self.levels.length + 1).include?(intersected_levels.length)
    self.valid_position_type?(job_listing)
  end

  def valid_position_type?(job_listing)
    intersected_positions = self.positions & job_listing.position_type
    intersected_positions.present? && (self.positions.length - 1..self.positions.length + 1).include?(intersected_positions.length)
  end
end
