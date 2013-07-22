# == Schema Information
#
# Table name: profiles
#
#  id                  :integer          not null, primary key
#  number_connections  :integer
#  number_recommenders :integer
#  summary             :text
#  skills              :string(255)      default([])
#  linkedin_id         :integer
#  created_at          :datetime
#  updated_at          :datetime
#

class Profile < ActiveRecord::Base
  attr_accessible :number_connections, :number_recommenders, :summary,
    :skills

  has_many :positions, dependent: :destroy
  has_many :educations, dependent: :destroy
  belongs_to :linkedin

  after_save :set_user_preference_skills

  def from_omniauth(profile=nil)
    profile                  = self.linkedin.get_profile unless profile.present?
    self.summary             = profile['summary']
    self.number_connections  = profile['numConnections']
    self.number_recommenders = profile['numRecommenders']
    self.skills              = self.class.get_skills(profile)
    self.save!
    Position.from_omniauth(profile, self.id, self.collected_position_keys)
    Education.from_omniauth(profile, self.id, self.collected_education_keys)
  end

  def collected_position_keys
    self.positions.collect { |pos| pos.company_key }
  end

  def collected_education_keys
    self.educations.collect { |edu| edu.education_key }
  end

  def self.get_skills(profile)
    if profile['skills'].present?
      profile['skills']['values'].inject([]) do |code_skills, collection|
        code_skills << collection['skill']['name']
        code_skills
      end
    end
  end

  private

  #set the skills they prefer, to the skills that are grabbed from linkedin
  def set_user_preference_skills
    self.linkedin.user.preference.set_skills(self.skills)
  end
end
