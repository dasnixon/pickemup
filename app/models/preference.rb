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
#  skills                 :json
#  locations              :json
#  industries             :json
#  positions              :json
#  settings               :json
#  dress_codes            :json
#  company_types          :json
#  perks                  :json
#  practices              :json
#  levels                 :json
#  user_id                :integer
#  created_at             :datetime
#  updated_at             :datetime
#

class Preference < ActiveRecord::Base
  LOCATIONS     = ['San Francisco, CA', 'Portland, OR', 'Seattle, WA',
                   'New York City, NY', 'Chicago, IL', 'Boston, MA',
                   'Austin, TX', 'Los Angeles, CA', 'Cincinnati, OH']

  INDUSTRIES    = ['Medical', 'Mobile', 'Education', 'Entertainment', 'Advertising', 'Scientific', 'Consumer Technology',
                   'Security', 'Transportation', 'Banking', 'Real Estate', 'Legal', 'Industrial', 'Gaming', 'Food',
                   'Fitness', 'Sports', 'Architecture', 'Agriculture', 'Art', 'Hardware', 'Non-profit']

  LEVELS        = ['Intern', 'Co-op', 'Junior Engineer', 'Mid-level Engineer', 'Senior-level Engineer', 'Executive']

  POSITIONS     = ['Associative Engineer', 'Software Engineer', 'DevOps Engineer', 'Senior Engineer', 'Staff Engineer', 'Engineering Manager',
                   'Principal Engineer', 'Senior Principal Engineer', 'Senior Engineering Manager', 'Architect', 'Director of Engineering',
                   'Senior Architect', 'Senior Director of Engineering', 'VP of Engineering', 'SVP of Engineering']

  SETTINGS      = ['Urban', 'Rural', 'Office Park']

  DRESS_CODES   = ['Professional', 'Business Casual', 'Casual']

  COMPANY_TYPES = ['Bootstrapped', 'VC Backed', 'Small Business', 'Publicly-Owned Business']

  PERKS         = ['Kegs', 'Ping-pong table', 'Snacks', 'Catered Meals', 'Offsites', 'Flexible Work Hours', 'Conference Travel',
                   'Work from Home', 'Lunch Stipend', 'Phone Stipend', 'Public Transit Stipend', 'Tuition Reimbursement', 'Choice of Equipment',
                   'Swag']

  PRACTICES     = ['Test-driven Development', 'Agile Development', 'Pair Programming', 'Behavior-driven Development', 'Scrum',
                   'Cowboy Coding', 'Object Oriented Design', 'Waterfall Model', 'Service-oriented Design', 'Don\'t Repeat Yourself (DRY)',
                   'Extreme Programming', 'Continuous Integration']

  REMOTE        = {0 => "No", 1 => "Yes", 2 => "I'm open to remote work"}

  COMPANY_SIZE  = {0 => "1-10 Employees", 1 => "11-50 Employees", 2 => "51-200 Employees", 3 => "201-500 Employees", 4 => "501+ Employees"}


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
    default_skills = self.skills || []
    new_skills = profile_skills.collect do |skill|
      {name: skill, checked: false} unless default_skills.any? { |hash| hash['name'] == skill }
    end
    self.skills = (default_skills + new_skills).compact.to_json
    self.save
  end

  def default_hash(attr)
    default_hash = self.send(attr) || []
    default_attributes = self.class.const_get(attr.upcase).collect do |value|
      {name: value, checked: false} unless default_hash.any? { |hash| hash['name'] == value }
    end
    (default_hash + default_attributes).to_json
  end

  def set_defaults
    %w(locations industries positions settings dress_codes company_types perks practices levels).each do |attr|
      self.send("#{attr}=", self.default_hash(attr))
    end
  end
end
