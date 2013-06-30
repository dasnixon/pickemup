class Profile < ActiveRecord::Base
  has_many :positions, dependent: :destroy
  has_many :educations, dependent: :destroy
  belongs_to :linkedin

  def from_omniauth
    profile = self.linkedin.get_profile
    self.summary = profile['summary']
    self.number_connections = profile['numConnections']
    self.number_recommenders = profile['numRecommenders']
    self.skills = self.class.format_skills(profile)
    self.save!
    Position.from_omniauth(profile, self.id)
    Education.from_omniauth(profile, self.id)
  end

  def self.format_skills(profile)
    if profile['skills'].present?
      profile['skills']['values'].inject([]) do |skills, collection|
        skills << collection['skill']['name']
        skills
      end
    end
  end
end
