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
  belongs_to :profile

  def self.from_omniauth(profile, id)
    if profile['educations'] && profile['educations'].has_key?('values')
      profile['educations']['values'].each do |education|
        edu = Education.find_or_initialize_by_education_key_and_profile_id(education['id'].to_s, id)
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
end
