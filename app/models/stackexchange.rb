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
#  badges            :hstore
#  display_name      :string(255)
#  nickname          :string(255)
#  stackexchange_key :string(255)
#  user_id           :integer
#  created_at        :datetime
#  updated_at        :datetime
#

class Stackexchange < ActiveRecord::Base
  attr_accessible :token, :uid, :profile_url, :reputation, :age,
    :badges, :display_name, :nickname, :stackexchange_key

  belongs_to :user

  after_create :set_user_synced
  after_destroy :unset_user_synced

  #the initial creation of a user's stackexchange account from their auth
  #information when they agree to link
  def from_omniauth(auth)
    self.update(
      uid:               auth.uid,
      nickname:          auth.info.nickname,
      token:             auth.credentials.token,
      profile_url:       auth.info.urls.stackoverflow,
      reputation:        auth.extra.raw_info.reputation,
      age:               auth.extra.raw_info.age,
      badges:            auth.extra.raw_info.badge_counts,
      display_name:      auth.extra.raw_info.display_name,
      stackexchange_key: auth.extra.raw_info.user_id
    )
  end

  #update information that could change from a user's stackoverflow account
  def update_stackexchange
    stackexchange_info = get_stackexchange_user
    self.update(
      display_name:  stackexchange_info.display_name,
      reputation:    stackexchange_info.reputation,
      age:           stackexchange_info.age,
      badges:        stackexchange_info.badge_counts
    )
  end

  #initialize the Stackexchange API with the user's oauth token
  def initialize_stackexchange
    @info ||= Serel::AccessToken.new(self.token)
  end

  #get user's information from stackoverflow which is the default lookup
  def get_stackexchange_user
    begin
      initialize_stackexchange.user
    rescue Exception => e
      logger.error "Stackexchange #get_stackexchange_user error #{e}"
    end
  end

  private

  def set_user_synced
    self.user.set_stackexchange_synced
  end

  def unset_user_synced
    self.user.set_stackexchange_unsynced
  end
end
