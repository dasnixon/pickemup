#This class is used for the form on the contact page http://pickemup.me/contact
class Contact
  include ActiveModel::Validations

  attr_accessor :name, :email, :phone, :message

  validates :name, :email, :phone, :message, presence: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validates :phone, phony_plausible: true

  def initialize(attrs = {})
    attrs.each do |key, value|
      update_attribute(key, value)
    end
  end

  def update_attribute(key, value)
    send "#{key}=", value
  end

  def email_address_with_name
    "#{self.name} <#{self.email}>"
  end

  def save
    if self.valid?
      Notifier.contact_us(self).deliver
      true
    else
      false
    end
  end
end
