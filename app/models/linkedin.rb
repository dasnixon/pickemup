# == Schema Information
#
# Table name: linkedins
#
#  id          :integer          not null, primary key
#  token       :string(255)
#  headline    :string(255)
#  industry    :string(255)
#  uid         :string(255)
#  profile_url :string(255)
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Linkedin < ActiveRecord::Base
  PROFILE_FIELDS = %w(summary positions languages num-connections industry
    skills certifications educations num-recommenders interests email-address
    first-name last-name headline public-profile-url)

  attr_accessible :token, :headline, :industry,
    :uid, :profile_url

  after_create :grab_user_information

  belongs_to :user
  has_one :profile, dependent: :destroy

  def from_omniauth(auth)
    self.token         = auth.credentials.token
    self.headline      = auth.info.description
    self.industry      = auth.extra.raw_info.industry
    self.uid           = auth.uid
    self.profile_url   = auth.extra.raw_info.publicProfileUrl
    self.save! if self.changed?
  end

  #get a user's profile information from linkedin using their oauth token
  def get_profile
    begin
      client.profile(fields: PROFILE_FIELDS)
    rescue Exception => e
      logger.error "Linkedin #get_profile error #{e}"
    end
  end

  #update any information about a user that may have changed on linkedin so we
  #always stay up-to-date
  def update_linkedin
    profile = self.get_profile
    self.update(
      headline: profile.headline,
      industry: profile.industry,
      profile_url: profile.public_profile_url
    )
    self.profile.from_omniauth(profile) if self.profile.present?
  end

  private

  def client
    LinkedIn::Client.new(ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET'], self.token)
  end

  def grab_user_information
    LinkedinWorker.perform_async(self.id)
  end
end
