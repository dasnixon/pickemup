# == Schema Information
#
# Table name: subscriptions
#
#  id                    :integer          not null, primary key
#  plan                  :integer
#  company_id            :integer          not null
#  stripe_customer_token :string(255)
#  stripe_card_token     :string(255)
#  active                :boolean          default(FALSE)
#  email                 :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#

class Subscription < ActiveRecord::Base
  attr_accessible :plan, :stripe_card_token, :stripe_customer_token,
    :active, :email
  belongs_to :company

  validates_presence_of :company_id, :plan, :stripe_card_token

  def save_with_payment
    if valid?
      customer = Stripe::Customer.create(:email => Company.find(self.company_id).email, :plan => plan, :card => stripe_card_token)
      self.stripe_customer_token = customer.id
      self.active = true
      save!
    end
    rescue Stripe::InvalidRequestError => e
      logger.error "Stripe error while creating customer: #{e.message}"
      errors.add :base, "There was a problem with your credit card."
      false
  end

  def save_update
    if valid?
      self.save!
    end
    rescue Stripe::InvalidRequestError => e
      logger.error "Stripe error while updating: #{e.message}"
      errors.add :base, "There was a problem updating."
      false
  end
end
