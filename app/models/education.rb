# == Schema Information
#
# Table name: educations
#
#  id             :integer          not null, primary key
#  activities     :text
#  degree         :string(255)
#  field_of_study :string(255)
#  notes          :text
#  school_name    :string(255)
#  start_year     :string(255)
#  end_year       :string(255)
#  education_key  :string(255)
#  profile_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class Education < ActiveRecord::Base
  attr_accessible :activities, :degree, :field_of_study, :notes,
    :school_name, :start_year, :end_year

  belongs_to :profile

  def self.from_omniauth(profile, pro_id, education_keys=nil)
    if profile['educations'] && profile['educations'].has_key?('values')
      Education.remove_educations(profile['educations']['values'], education_keys) if education_keys.present?
      profile['educations']['values'].each do |education|
        edu = Education.find_or_initialize_by_education_key_and_profile_id(education['id'].to_s, pro_id)
        edu.update_attributes(
          activities:     education['activities'],
          degree:         education['degree'],
          field_of_study: education['fieldOfStudy'],
          notes:          education['notes'],
          school_name:    education['schoolName'],
          start_year:     education['startDate']['year'],
          end_year:       education['endDate']['year']
        )
      end
    end
  end

  def self.remove_educations(educations, education_keys)
    (education_keys - educations.collect { |edu| edu['id'].to_s }).each do |diff_id|
      Education.where(education_key: diff_id).first.try(:destroy)
    end
  end
end
