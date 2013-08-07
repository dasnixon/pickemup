# == Schema Information
#
# Table name: preferences
#
#  id                     :integer          not null, primary key
#  healthcare             :boolean          default(FALSE)
#  dentalcare             :boolean          default(FALSE)
#  visioncare             :boolean          default(FALSE)
#  life_insurance         :boolean          default(FALSE)
#  paid_vacation          :boolean          default(FALSE)
#  equity                 :boolean          default(FALSE)
#  bonuses                :boolean          default(FALSE)
#  retirement             :boolean          default(FALSE)
#  fulltime               :boolean          default(TRUE)
#  us_citizen             :boolean          default(FALSE)
#  open_source            :boolean          default(FALSE)
#  remote                 :boolean          default(FALSE)
#  expected_salary        :integer          default(0)
#  potential_availability :integer          default(0)
#  work_hours             :integer          default(0)
#  company_size           :string(255)      default([])
#  skills                 :string(255)      default([])
#  locations              :string(255)      default([])
#  industries             :string(255)      default([])
#  positions              :string(255)      default([])
#  settings               :string(255)      default([])
#  dress_codes            :string(255)      default([])
#  company_types          :string(255)      default([])
#  perks                  :string(255)      default([])
#  practices              :string(255)      default([])
#  levels                 :string(255)      default([])
#  user_id                :integer
#  created_at             :datetime
#  updated_at             :datetime
#

class Preference < ActiveRecord::Base
  include PreferenceConstants

  attr_accessible :healthcare, :dentalcare, :visioncare, :life_insurance, :paid_vacation,
    :equity, :bonuses, :retirement, :fulltime, :remote, :open_source, :expected_salary,
    :potential_availability, :company_size, :work_hours, :skills, :locations,
    :industries, :positions, :settings, :dress_codes, :company_types, :perks,
    :practices, :levels, :us_citizen

  belongs_to :user

  validates :expected_salary, numericality: true, inclusion: { in: 0..99999999, message: 'Nice try money bags.' }
  validates :work_hours, numericality: true, inclusion: { in: 0..168, message: 'Are you a machine?' }
  validates :potential_availability, numericality: true, inclusion: { in: 0..52, message: 'Start sooner!' }

  def default_hash
    { healthcare: self.healthcare, dentalcare: self.dentalcare, visioncare: self.visioncare,
      life_insurance: self.life_insurance, paid_vacation: self.paid_vacation, equity: self.equity,
      bonuses: self.bonuses, retirement: self.retirement, fulltime: self.fulltime, remote: self.remote,
      open_source: self.open_source, expected_salary: self.expected_salary, us_citizen: self.us_citizen,
      potential_availability: self.potential_availability, work_hours: self.work_hours }
  end

  def get_preference_defaults
    %w(locations industries positions settings dress_codes company_types perks practices levels company_size skills).inject(self.default_hash) do |default_hash, attr|
      default_hash[attr] = get_attr_values(attr)
      default_hash
    end
  end

  def get_attr_values(attr)
    self.attribute_default_values(attr).inject([]) do |attr_array, value|
      if self.send(attr).include?(value) #if user has checked this value for this particular attribute
        attr_array << { name: value, checked: true } #set it into the returned hash for angular
      else
        attr_array << { name: value, checked: false } #set it into the returned hash for angular
      end
      attr_array
    end
  end

  def attribute_default_values(attr)
    if attr == 'skills'
      current_user = self.user
      if current_user.linkedin_uid.present?
        current_user.linkedin.profile.skills
      else
        []
      end
    else
      self.class.const_get(attr.upcase)
    end
  end

  def self.cleanup_invalid_data(params)
    %w(locations industries positions settings dress_codes company_types perks practices levels company_size skills).each do |attr|
      unless params.has_key?(attr) && params[attr] && params[attr].is_a?(Array)
        params.delete(attr)
        next
      end
      params[attr] = params[attr].reject do |attributes|
        !(attributes.has_key?('checked') && attributes.has_key?('name')) ||
          attributes.keys.length > 2 ||
          ![TrueClass, FalseClass].include?(attributes['checked'].class) ||
          !attributes['checked']
      end
      params[attr].collect! { |attrs| attrs['name'] }
    end
    params
  end
end
