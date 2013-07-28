# == Schema Information
#
# Table name: companies
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  email         :string(255)
#  password_salt :string(255)
#  password_hash :string(255)
#  description   :string(255)
#  website       :string(255)
#  industry      :string(255)
#  num_employees :string(255)
#  public        :boolean          default(FALSE)
#  founded       :date
#  created_at    :datetime
#  updated_at    :datetime
#

class Company < ActiveRecord::Base
  attr_accessible :name, :email, :description, :website,
    :industry, :password_salt, :password_hash, :description,
    :num_employees, :public, :founded, :password
  attr_accessor :password
  before_save :encrypt_password
  before_update :clean_url, if: :website_changed? #TODO fix this validation

  validates_confirmation_of :password, :message => "Password/Password Confirmation is invalid"
  validates_presence_of :password, :on => :create
  validates_presence_of :email
  validates_uniqueness_of :email
  validate :password_strength, :on => :create
  validates_format_of :email, :with => /[\w|\d]{1,}@[\w|\d]*[.][\w|\d]*/, :message => "Email is invalid."

  has_one :subscription
  has_many :job_listings

  acts_as_messageable

  def password_strength
    errors.add(:password_length, "Password must be at least 8 characters") unless password.length >= 8
  end

  def clean_url
    new_url = website.gsub(/(https{0,1}:\/\/)|(www)./, "").prepend("http://")
    self.website = new_url
  end

  def self.authenticate(email, password)
    company = find_by_email(email)
    if company && company.password_hash == BCrypt::Engine.hash_secret(password, company.password_salt)
      company
    else
      nil
    end
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
end
