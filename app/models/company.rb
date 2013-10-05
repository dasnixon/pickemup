# == Schema Information
#
# Table name: companies
#
#  id                 :uuid             not null, primary key
#  name               :string(255)
#  email              :string(255)
#  password_salt      :string(255)
#  password_hash      :string(255)
#  description        :text
#  website            :string(255)
#  industry           :string(255)
#  num_employees      :string(255)
#  public             :boolean          default(FALSE)
#  founded            :date
#  created_at         :datetime
#  updated_at         :datetime
#  acquired_by        :string(255)
#  tags               :string(255)      default([])
#  total_money_raised :string(255)
#  competitors        :string(255)      default([])
#  logo               :string(255)
#  verified           :boolean          default(FALSE)
#  last_sign_in_at    :datetime
#  current_sign_in_at :datetime
#  last_sign_in_ip    :inet
#  current_sign_in_ip :inet
#  sign_in_count      :integer
#  size_definition    :string(255)
#  active             :boolean          default(TRUE)
#

class Company < ActiveRecord::Base
  acts_as_messageable #mailboxer

  include Shared
  include JobListingMessages #override mailboxer .send_message
  include Trackable
  include PickemupAPI

  autocomplete :name, score: :calculate_score

  mount_uploader :logo, AvatarUploader #carrierwave
  process_in_background :logo

  attr_accessor :password

  before_save :encrypt_password, if: :password
  before_update :clean_url, if: :website_changed? #TODO fix this validation
  after_create :process_sign_up

  validates :password, presence:     true,
                       confirmation: { message: 'Password/Password Confirmation do not match.' },
                       length:       { :minimum => 6 },
                       if:           :password
  validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validates :name, presence: true, uniqueness: true
  validates :size_definition, inclusion: { in: PreferenceConstants::COMPANY_TYPES }, allow_blank: true

  has_one :subscription, dependent: :destroy
  has_many :job_listings, dependent: :destroy
  has_many :tech_stacks, dependent: :destroy

  def active_listings
    self.job_listings.select { |listing| listing.active }
  end

  def calculate_score
    self.num_employees.present? ? self.num_employees.to_i : 1
  end

  def get_logo
    self.logo.present? ? self.logo : 'default_logo.png'
  end

  def set_verified
    self.verified = true
    self.save
  end

  def save_with_tracking_info(request)
    self.update_tracked_fields!(request)
    self.save
  end

  def collected_tech_stacks
    self.tech_stacks.collect { |stack| { name: stack.name, id: stack.id } }
  end

  def clean_error_messages
    error_message = self.errors.messages.inject([]) do |clean_message, (error, message)|
      clean_message << "#{error.capitalize} #{message.to_sentence(two_words_connector: ' and ', last_word_connector: ', and ')}"
      clean_message
    end
    error_message.to_sentence(two_words_connector: ' and ', last_word_connector: ', and ')
  end

  #Uses the crunchbase api to pre-populate information regarding companies
  def get_crunchbase_info
    begin
      info = Crunchbase::Company.get(self.name)
      self.process_logo_upload = true
      self.website             = info.homepage_url
      self.num_employees       = info.number_of_employees
      self.public              = info.ipo ? true : false
      self.description         = info.overview.present? ? info.overview : info.description
      self.founded             = info.founded
      self.total_money_raised  = info.total_money_raised
      self.tags                = info.tags
      self.remote_logo_url     = "http://crunchbase.com/#{info.image.first.flatten[-1]}" if info.image
      self.competitors         = info.competitions.map { |company| company["competitor"]["name"] } if info.competitions
    rescue Exception => e
      logger.error "Company #get_crunchbase_info error #{e}"
    ensure
      self.save
    end
  end

  def clean_url
    new_url = website.gsub(/(https{0,1}:\/\/)|(www)./, "").prepend("http://")
    self.website = new_url
  end

  def self.authenticate(email, password, request)
    company = find_by(email: email)
    if company && company.password_hash == BCrypt::Engine.hash_secret(password, company.password_salt)
      company.save_with_tracking_info(request)
      company
    else
      nil
    end
  end

  def fully_activated?
    self.active? and self.subscription and self.subscription.active?
  end

  def api_attributes
    attrs = self.attributes
    attrs.merge!(company_id: attrs.delete("id"))
  end

  def conversation_for_job_listing(job_listing_id)
    self.mailbox.conversations.find_by(job_listing_id: job_listing_id)
  end

  def already_has_conversation_over?(job_listing_id, user)
    conversation = conversation_for_job_listing(job_listing_id) and
      conversation.is_participant?(user)
  end

  def match_users_per_listing
    self.job_listings.inject({}) do |matches, job_listing|
      matches["#{job_listing.job_title}___#{job_listing.id}"] ||= []
      User.all.find_in_batches do |batched_users|
        batched_users.each do |user|
          next matches if matches["#{job_listing.job_title}___#{job_listing.id}"].length >= 25 or self.already_has_conversation_over?(job_listing.id, user)
          user_attrs = user.attributes.keep_if { |k,v| k =~ /^id$|name|description|location/ }.merge('profile_image' => user.profile_image.url(:medium))
          preference_attrs = user.preference.attributes.keep_if { |k,v| k =~ /salary|skills|locations|expected_salary/ }.merge('score' => user.preference.score(job_listing.id)['score'].to_i)
          matches["#{job_listing.job_title}___#{job_listing.id}"] << user_attrs.merge(preference_attrs)
        end
      end
      matches["#{job_listing.job_title}___#{job_listing.id}"].sort_by { |match| match['score'] }.reverse!
      matches
    end
  end

  private

  def encrypt_password
    self.password_salt = BCrypt::Engine.generate_salt
    self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
  end

  def process_sign_up
    CrunchbaseWorker.perform_async(self.id)
  end
end
