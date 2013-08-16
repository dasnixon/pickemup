# == Schema Information
#
# Table name: users
#
#  id                   :integer          not null, primary key
#  github_uid           :string(255)
#  linkedin_uid         :string(255)
#  email                :string(255)
#  name                 :string(255)
#  location             :string(255)
#  profile_image        :string(255)
#  main_provider        :string(255)
#  description          :text
#  created_at           :datetime
#  updated_at           :datetime
#  stackexchange_synced :boolean          default(FALSE)
#

class User < ActiveRecord::Base
  acts_as_messageable #mailboxer

  include LinkedinLogin
  include GithubLogin
  include JobListingMessages #override mailboxer .send_message
  include Trackable

  has_one :github_account, dependent: :destroy
  has_one :linkedin, dependent: :destroy
  has_one :stackexchange, dependent: :destroy
  has_one :preference, dependent: :destroy

  attr_accessor :newly_created

  attr_accessible :github_uid, :linkedin_uid, :email, :name, :location,
    :current_company, :description, :profile_image, :main_provider

  after_create :create_preference

  mount_uploader :profile_image, AvatarUploader #carrierwave

  #find or create a user from auth then update information on that user
  def self.from_omniauth(auth, provider)
    case provider
      when :github
        User.where(github_uid: auth.uid).first_or_create do |user|
          user.set_user_github_information(auth)
        end.tap do |user|
          StoreUserProfileImage.perform_async(user.id, auth.info.image) unless user.main_provider == 'linkedin'
          if !user.newly_created
            user.main_provider == 'linkedin' ? UserInformationWorker.perform_async(user.id) : user.update_github_information(auth)
          end
        end
      when :linkedin
        User.where(linkedin_uid: auth.uid).first_or_create do |user|
          user.set_user_linkedin_information(auth)
        end.tap do |user|
          StoreUserProfileImage.perform_async(user.id, auth.info.image) unless user.main_provider == 'github'
          if !user.newly_created
            user.main_provider == 'github' ? UserInformationWorker.perform_async(user.id) : user.update_linkedin_information(auth)
          end
        end
      else
        nil
    end
  end

  #called from the UserInformationWorker sidekiq job to consistently update
  #user's information when they log back in to our application
  def update_resume
    self.github_account.setup_information if self.github_uid.present?
    self.linkedin.update_linkedin if self.linkedin_uid.present?
    self.stackexchange.update_stackexchange if self.stackexchange_synced?
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

  def set_stackexchange_unsynced
    self.stackexchange_synced = false
    self.save!
  end

  private

  #automatically generate a defaulted preference for a user upon creation
  def create_preference
    self.build_preference.save
  end
end
