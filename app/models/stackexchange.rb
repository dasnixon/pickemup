# == Schema Information
#
# Table name: stackexchanges
#
#  id                :integer          not null, primary key
#  token             :string(255)
#  uid               :string(255)
#  profile_url       :string(255)
#  reputation        :integer
#  age               :integer
#  profile_image     :string(255)
#  badges            :hstore
#  display_name      :string(255)
#  nickname          :string(255)
#  stackexchange_key :string(255)
#  user_id           :integer
#  created_at        :datetime
#  updated_at        :datetime
#

class Stackexchange < ActiveRecord::Base
  belongs_to :user

  def from_omniauth(auth)
    self.uid               = auth.uid
    self.nickname          = auth.info.nickname
    self.token             = auth.credentials.token
    self.profile_url       = auth.info.urls.stackoverflow
    self.reputation        = auth.extra.raw_info.reputation
    self.age               = auth.extra.raw_info.age
    self.profile_image     = auth.info.image
    self.badges            = auth.extra.raw_info.badge_counts
    self.display_name      = auth.extra.raw_info.display_name
    self.stackexchange_key = auth.extra.raw_info.user_id
    self.save!
  end
end
