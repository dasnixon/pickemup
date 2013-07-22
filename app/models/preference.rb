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
  include PreferenceConstants

  attr_accessible :healthcare, :dentalcare, :visioncare, :life_insurance, :paid_vacation,
    :equity, :bonuses, :retirement, :fulltime, :remote, :open_source, :expected_salary,
    :potential_availability, :company_size, :work_hours, :skills, :locations,
    :industries, :positions, :settings, :dress_codes, :company_types, :perks,
    :practices, :levels, :us_citizen

  belongs_to :user

  validates :expected_salary, numericality: true, inclusion: { in: 0..20000000 }
  validates :work_hours, numericality: true, inclusion: { in: 0..168 }

  before_validation :cleanup_invalid_data, unless: Proc.new { |instance| instance.new_record? }

  def set_skills(profile_skills)
    new_skills = profile_skills.collect do |skill|
      {name: skill, checked: false} unless self.skills.any? { |hash| hash['name'] == skill }
    end
    self.skills = (self.skills + new_skills).compact.to_json
    self.save
  end

  def default_hash(attr)
    default_attributes = self.class.const_get(attr.upcase).collect do |value|
      {name: value, checked: false} unless self.send(attr).any? { |hash| hash['name'] == value }
    end
    (self.send(attr) + default_attributes).compact.to_json
  end

  def set_defaults
    %w(locations industries positions settings dress_codes company_types perks practices levels remote company_size).each do |attr|
      self.send("#{attr}=", self.default_hash(attr))
    end
  end

  def reject_invalid_data(attr)
    attrs_changed = (self.send(attr) - self.send("#{attr}_was"))
    names = self.send(attr).collect { |hash| hash['name'] }
    self.send(attr).uniq!
    attrs_changed.each do |hash| #reject any data if:
      if !hash.is_a?(Hash) || #element of array is not a hash
           !(['name', 'checked'].all? { |k| hash.has_key?(k) }) || #hash does not have 'name' and 'checked' keys
           hash.keys.length >= 3 || #hash has more than 3 keys (should only have 2)
           !self.class.const_get(attr.upcase).include?(hash['name']) || #the name value is not a default in constants
           ![TrueClass, FalseClass].include?(hash['checked'].class) || #the checked value is not a boolean
           names.count(hash['name']) > 1 #check if name repeats itself more than once (duplicate)
        self.send("#{attr}=", (self.send(attr) - [hash]))
      end
    end
  end

  private

  def cleanup_invalid_data
    %w(locations industries positions settings dress_codes company_types perks practices levels remote company_size).each do |attr|
      next unless self.send("#{attr}_changed?")
      if !self.send(attr).is_a?(Array)
        self.send("#{attr}=", [])
        next
      end
      reject_invalid_data(attr)
    end
  end
end
