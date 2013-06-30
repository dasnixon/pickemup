class Education < ActiveRecord::Base
  belongs_to :profile

  def self.from_omniauth(profile, id)
    if profile['educations'] && profile['educations'].has_key?('values')
      profile['educations']['values'].each do |education|
        Education.create(profile_id: id) do |e|
          e.activities     = education['activities']
          e.degree         = education['degree']
          e.field_of_study = education['fieldOfStudy']
          e.notes          = education['notes']
          e.school_name    = education['schoolName']
          e.education_key  = education['id']
          e.start_year     = education['startDate']['year']
          e.end_year       = education['endDate']['year']
        end
      end
    end
  end
end
