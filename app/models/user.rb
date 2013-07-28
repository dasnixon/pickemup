# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  uid             :string(255)
#  email           :string(255)
#  name            :string(255)
#  location        :string(255)
#  blog            :string(255)
#  current_company :string(255)
#  description     :text
#  created_at      :datetime
#  updated_at      :datetime
#

class User < ActiveRecord::Base
  acts_as_messageable

  has_one :github_account, dependent: :destroy
  has_one :linkedin, dependent: :destroy
  has_one :stackexchange, dependent: :destroy
  has_one :preference, dependent: :destroy

  attr_accessor :newly_created
  attr_accessible :uid, :email, :name, :location,
    :blog, :current_company, :description, :profile_image

  after_create :create_preference

  def self.from_omniauth(auth)
    User.where(auth.slice(:uid)).first_or_create do |user|
      user.newly_created = true
      user.set_attributes(auth)
      user.build_github_account.from_omniauth(auth)
    end.tap do |user| #update user's token in case it has expired/changed
      user.update_information(auth) unless user.newly_created
    end
  end

  def has_linkedin_synced?
    self.linkedin.try(:uid).present?
  end

  def has_stackexchange_synced?
    self.stackexchange.try(:uid).present?
  end

  def update_resume
    self.github_account.setup_information
    self.linkedin.update_linkedin if self.has_linkedin_synced?
    self.stackexchange.update_stackexchange if self.has_stackexchange_synced?
  end

  def update_information(auth)
    UserInformationWorker.perform_async(self.id) #this will call the update_resume method
    self.set_attributes(auth)
    self.github_account.from_omniauth(auth)
  end

  def set_attributes(auth)
    info                 = auth.info
    extra_info           = auth.extra.raw_info
    self.name            = info.name
    self.email           = info.email
    self.profile_image   = info.image
    self.location        = extra_info.location
    self.blog            = extra_info.blog
    self.current_company = extra_info.company
    self.save! if !self.newly_created && self.changed?
  end

  def mailboxer_email(object)
    self.email
  end

  def mailboxer_name
    self.name
  end

  private

  def create_preference
    self.build_preference.save
  end
end
