# == Schema Information
#
# Table name: companies
#
#  id                 :integer          not null, primary key
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
#

class Company < ActiveRecord::Base
  acts_as_messageable #mailboxer

  include JobListingMessages #override mailboxer .send_message

  attr_accessible :name, :email, :description, :website,
    :industry, :password_salt, :password_hash, :description,
    :num_employees, :public, :founded, :password, :logo

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

  has_one :subscription
  has_many :job_listings
  has_many :tech_stacks

  def get_logo
    self.logo.present? ? self.logo : 'default_logo.png'
  end

  def set_verified
    self.verified = true
    self.save
  end

  def clean_error_messages
    error_message = self.errors.messages.inject([]) do |clean_message, (error, message)|
      clean_message << "#{error.capitalize} #{message.join(' ')}"
      clean_message
    end
    error_message.to_sentence(two_words_connector: ' and ', last_word_connector: ', and ')
  end

  #Uses the crunchbase api to pre-populate information regarding companies
  def get_crunchbase_info
    begin
      info = Crunchbase::Company.get(self.name)
      self.website = info.homepage_url
      self.num_employees = info.number_of_employees
      self.public = info.ipo ? true : false
      self.description = info.overview.present? ? info.overview : info.description
      self.founded = info.founded
      self.total_money_raised = info.total_money_raised
      self.tags = info.tags
      self.logo = "http://crunchbase.com/#{info.image.first.flatten[-1]}" if info.image
      self.competitors = info.competitions.map { |company| company["competitor"]["name"] } if info.competitions
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

  def self.authenticate(email, password)
    company = find_by(email: email)
    if company && company.password_hash == BCrypt::Engine.hash_secret(password, company.password_salt)
      company
    else
      nil
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
