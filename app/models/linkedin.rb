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
  def from_omniauth(auth)
    self.token       = auth.credentials.token
    self.headline    = auth.info.description
    self.industry    = auth.extra.raw_info.industry
    self.uid         = auth.uid
    self.profile_url = auth.extra.raw_info.publicProfileUrl
    self.save!
  end
end
