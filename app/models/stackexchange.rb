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
