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
  include LinkedinApi

  after_create :grab_user_information

  has_one :profile, dependent: :destroy

  def from_omniauth(auth)
    self.token         = auth.credentials.token
    self.headline      = auth.info.description
    self.industry      = auth.extra.raw_info.industry
    self.uid           = auth.uid
    self.profile_url   = auth.extra.raw_info.publicProfileUrl
    self.save!
  end

  def get_profile(options={})
    path = person_path(options)
    simple_query(path, {oauth2_access_token: self.token, format: 'json'})
  end

  def get_connections(options={})
    path = "#{person_path(options)}/connections"
    simple_query(path, {oauth2_access_token: self.token, format: 'json'})
  end

  private

  def grab_user_information
    LinkedinWorker.perform_async(self.id)
  end
end
