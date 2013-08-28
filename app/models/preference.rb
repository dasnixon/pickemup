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

#http://www.postgresql.org/docs/7.3/static/functions-matching.html
#SELECT * FROM ( SELECT *, unnest(skills) s FROM preferences) x WHERE s ~* 'ruby';

class Preference < ActiveRecord::Base
  include PreferenceConstants
  include PreferencesHelper

  HASHABLE_PARAMS = %w(locations industries positions settings dress_codes company_types perks
    practices levels company_size skills)
  BENEFIT_ATTRS = %w(paid_vacation healthcare visioncare dentalcare life_insurance us_citizen equity
    bonuses retirement fulltime open_source remote)

  belongs_to :user

  validates :expected_salary, numericality: true, inclusion: { in: 0..99999999, message: 'Nice try money bags.' }
  validates :work_hours, numericality: true, inclusion: { in: 0..168, message: 'Are you a machine?' }
  validates :potential_availability, numericality: true, inclusion: { in: 0..52, message: 'Start sooner!' }

  def attribute_default_values(attr)
    case attr
      when 'skills'
        preference_user = self.user
        preference_user.linkedin_uid ? preference_user.linkedin.profile.skills.sort : []
      else
        self.class.const_get(attr.upcase)
    end
  end

  def benefits_section_filled?
    BENEFIT_ATTRS.any? { |attr| Preference.columns_hash[attr].default != self.send(attr) }
  end

  def ignored_columns
    @ignored ||= Preference.columns.select { |col| ignored_column?(col) }
  end

  def ignored_column?(col)
    col.name =~ /(user_id|id)/ || col.type.to_s =~ /(datetime)/ || BENEFIT_ATTRS.include?(col.name)
  end

  def preference_total_filled
    current_total = Preference.columns.inject(0) do |total, col|
      next total if ignored_columns.include?(col)
      self.send(col.name) == col.default ? total : total + 1
    end
    benefits_section_filled? ? current_total + 1 : current_total
  end

  def preference_percentage_filled #add +1 for the benefits section, which is considered one change in itself
    (self.preference_total_filled.to_f / (Preference.columns.length - ignored_columns.length + 1)) * 100
  end
end
