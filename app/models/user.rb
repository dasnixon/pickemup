# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  github_uid             :string(255)
#  linkedin_uid           :string(255)
#  email                  :string(255)
#  name                   :string(255)
#  location               :string(255)
#  profile_image          :string(255)
#  main_provider          :string(255)
#  description            :text
#  created_at             :datetime
#  updated_at             :datetime
#  stackexchange_synced   :boolean          default(FALSE)
#  last_sign_in_at        :datetime
#  current_sign_in_at     :datetime
#  last_sign_in_ip        :inet
#  current_sign_in_ip     :inet
#  sign_in_count          :integer
#  manually_setup_profile :boolean          default(FALSE)
#  active                 :boolean          default(TRUE)
#

class User < ActiveRecord::Base
  acts_as_messageable #mailboxer

  include Shared
  include Login
  include JobListingMessages #override mailboxer .send_message
  include Trackable

  has_one :github_account, dependent: :destroy
  has_one :linkedin, dependent: :destroy
  has_one :stackexchange, dependent: :destroy
  has_one :preference, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }

  attr_accessor :newly_created, :request, :track

  after_create :create_preference

  mount_uploader :profile_image, AvatarUploader #carrierwave

  class << self
    #find or create a user from auth then update information on that user
    def from_omniauth(auth, provider, request=nil, track=false)
      case provider
        when :github
          from_github_account(auth, provider, request, track)
        when :linkedin
          from_linkedin(auth, provider, request, track)
        else
          nil
      end
    end

    %w(github_account linkedin).each do |method|
      associated = method == 'github_account' ? 'github' : method
      define_method "from_#{method}" do |auth, provider, request=nil, track=false|
        User.where("#{associated}_uid" => auth.uid).first_or_initialize do |user|
          user.request, user.track = request, track
          return nil unless user.send("set_user_#{method}_information", auth)
        end.tap do |user|
          user.request, user.track = request, track unless user.newly_created
          user.send("post_#{method}_setup", auth)
        end
      end
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

  def matching_companies
    return nil unless self.active?
    linkedin = self.linkedin
    if linkedin
      profile = linkedin.profile
      if profile && profile.skills.present?
        where_lang_statement = profile.skills.collect { |j| "j ~* '#{j}'" }.join(' OR ')
        query = "SELECT * FROM ( SELECT *, unnest(acceptable_languages) j FROM job_listings) x WHERE #{where_lang_statement}"
        pref = self.preference
        JobListing.find_by_sql(query).uniq.collect { |job_listing| {job_listing: job_listing, company: job_listing.company, score: Algorithm.new(pref, job_listing).score} }
      end
    end
  end

  def search_attributes(job_listing_id)
    user_attrs = self.attributes.keep_if { |k,v| k =~ /^id$|name|profile_image|description|location/ }
    preference_attrs = self.preference.attributes.keep_if { |k,v| k =~ /salary|skills/ }.merge(score: self.preference.score(job_listing_id)['score'])
    user_attrs.merge(preference_attrs)
  end

  def get_user_skills
    linkedin_skills = self.linkedin_uid ? self.linkedin.profile.skills : []
    github_skills = self.github_uid ? self.github_account.skills : []
    (github_skills + linkedin_skills).uniq.sort
  end

  private

  #automatically generate a defaulted preference for a user upon creation
  def create_preference
    self.build_preference.save
    self.preference.api_create
  end
end
