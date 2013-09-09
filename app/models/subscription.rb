# == Schema Information
#
# Table name: subscriptions
#
#  id                    :uuid             not null, primary key
#  plan                  :integer
#  company_id            :uuid             not null
#  stripe_customer_token :string(255)
#  stripe_card_token     :string(255)
#  active                :boolean          default(FALSE)
#  email                 :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  started_at            :datetime
#

class Subscription < ActiveRecord::Base
  belongs_to :company

  validates :plan, :stripe_card_token, presence: true

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

  def maxed_out?
    (self.company.active_listings.count >= max_job_listings) || !self.active || expired?
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
