# == Schema Information
#
# Table name: profiles
#
#  id                  :integer          not null, primary key
#  number_connections  :integer
#  number_recommenders :integer
#  summary             :text
#  skills              :string(255)
#  linkedin_id         :integer
#  created_at          :datetime
#  updated_at          :datetime
#

class Profile < ActiveRecord::Base
  has_many :positions, dependent: :destroy
  has_many :educations, dependent: :destroy
  belongs_to :linkedin

  def from_omniauth(profile=nil)
    profile                  = self.linkedin.get_profile unless profile.present?
    self.summary             = profile['summary']
    self.number_connections  = profile['numConnections']
    self.number_recommenders = profile['numRecommenders']
    self.skills              += self.format_skills(profile)
    self.save!
    Position.from_omniauth(profile, self.id)
    Education.from_omniauth(profile, self.id)
  end

  def format_skills(profile)
    if profile['skills'].present?
      profile['skills']['values'].inject([]) do |code_skills, collection|
        code_skills << collection['skill']['name'] unless self.skills.include?(collection['skill']['name'])
        code_skills
      end
    end
  end
end
