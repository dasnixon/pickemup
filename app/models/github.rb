# == Schema Information
#
# Table name: githubs
#
#  id                 :integer          not null, primary key
#  nickname           :string(255)
#  profile_image      :string(255)
#  hireable           :boolean
#  bio                :text
#  public_repos_count :integer
#  number_followers   :integer
#  number_following   :integer
#  number_gists       :integer
#  token              :string(255)
#  user_id            :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class Github < ActiveRecord::Base
  belongs_to :user

  def from_omniauth(auth)
    info                    = auth.info
    extra_info              = auth.extra.raw_info
    self.nickname           = info.nickname
    self.profile_image      = info.image
    self.hireable           = extra_info.hireable
    self.bio                = extra_info.bio
    self.public_repos_count = extra_info.public_repos
    self.number_followers   = extra_info.followers
    self.number_following   = extra_info.following
    self.number_gists       = extra_info.public_gists
    self.token              = auth.credentials.token
    self.save!
  end
end
