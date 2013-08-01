# == Schema Information
#
# Table name: users
#
#  id                   :integer          not null, primary key
#  uid                  :string(255)
#  email                :string(255)
#  name                 :string(255)
#  location             :string(255)
#  blog                 :string(255)
#  current_company      :string(255)
#  profile_image        :string(255)
#  description          :text
#  created_at           :datetime
#  updated_at           :datetime
#  linkedin_synced      :boolean          default(FALSE)
#  stackexchange_synced :boolean          default(FALSE)
#

class User < ActiveRecord::Base
  has_one :github_account, dependent: :destroy
  has_one :linkedin, dependent: :destroy
  has_one :stackexchange, dependent: :destroy
  has_one :preference, dependent: :destroy

  attr_accessor :newly_created

  attr_accessible :uid, :email, :name, :location,
    :blog, :current_company, :description, :profile_image

  after_create :create_preference

  acts_as_messageable #mailboxer
  mount_uploader :profile_image, AvatarUploader #carrierwave

  #find or create a user from auth then update information on that user
  def self.from_omniauth(auth)
    User.where(auth.slice(:uid)).first_or_create do |user|
      user.newly_created = true
      user.set_attributes(auth)
      user.build_github_account.from_omniauth(auth)
    end.tap do |user| #update user's token in case it has expired/changed
      StoreUserProfileImage.perform_async(user.id, auth.info.image)
      user.update_information(auth) unless user.newly_created
    end
  end

  #called from the UserInformationWorker sidekiq job to consistently update
  #user's information when they log back in to our application
  def update_resume
    self.github_account.setup_information
    self.linkedin.update_linkedin if self.linkedin_synced?
    self.stackexchange.update_stackexchange if self.stackexchange_synced?
  end

  #update information for a persisted user (not a new user) including all their
  #github, linkedin, and stackexchange information, and any updated inforation
  #on the user
  def update_information(auth)
    UserInformationWorker.perform_async(self.id) #this will call the update_resume method
    self.set_attributes(auth)
    self.github_account.from_omniauth(auth)
  end

  #set attributes from the auth information on the user
  def set_attributes(auth)
    info                          = auth.info
    extra_info                    = auth.extra.raw_info
    self.name                     = info.name
    self.email                    = info.email
    self.location                 = extra_info.location
    self.blog                     = extra_info.blog
    self.current_company          = extra_info.company
    self.save! if !self.newly_created && self.changed?
  end

  #saves the user's profile image from github to S3 using carrierwave/fog
  def set_user_image(image_url)
    self.remote_profile_image_url = image_url
    self.save! if self.changed?
  end

  #the email address to be used by mailboxer to send emails to user when they
  #get messages
  def mailboxer_email(object)
    self.email
  end

  #the name to be used by mailboxer
  def mailboxer_name
    self.name
  end

  def set_stackexchange_synced
    self.stackexchange_synced = true
    self.save!
  end

  def set_linkedin_synced
    self.linkedin_synced = true
    self.save!
  end

  private

  #automatically generate a defaulted preference for a user upon creation
  def create_preference
    self.build_preference.save
  end
end
