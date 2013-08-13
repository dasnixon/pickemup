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
#  started_at            :datetime
#

class Subscription < ActiveRecord::Base
  attr_accessible :plan, :stripe_card_token, :stripe_customer_token,
    :active, :email, :max_job_listings, :started_at
  belongs_to :company

  validates_presence_of :company_id, :plan, :stripe_card_token

  PLAN_TO_OPTIONS_MAPPING = { 1 => {"time_limit" => 1.month, "max_job_listings" => 1},
                              2 => {"time_limit" => 1.month, "max_job_listings" => 5},
                              3 => {"time_limit" => 1.month, "max_job_listings" => 100} }

  def save_with_payment
    if valid?
      customer = Stripe::Customer.create(email: email, plan: plan, card: stripe_card_token)
      self.stripe_customer_token = customer.id
      self.active = true
      self.started_at = Time.zone.now
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

  def update_plan(plan_type)
    self.started_at = Time.zone.now
    self.plan = plan_type
  end

  def maxed_out?(num_listings)
    (num_listings >= max_job_listings) || !self.active || expired?
  end

  def expired?
    Time.now  > (self.started_at + PLAN_TO_OPTIONS_MAPPING[self.plan]["time_limit"])
  end

  def max_job_listings
    PLAN_TO_OPTIONS_MAPPING[self.plan]["max_job_listings"]
  end

  def retrieve_stripe_info
    begin
      Stripe::Customer.retrieve(self.stripe_customer_token)
    rescue Exception
      nil
    end
  end
end
