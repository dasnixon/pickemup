module Shared
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where active: true }
  end

  def toggle_activation
    self.active = !self.active
    self.save
    check_for_company_and_stripe
  end

  def check_for_company_and_stripe
    if self.is_a? Company and sub = self.subscription and customer = sub.retrieve_stripe_info
      if !self.active?
        stripe_sub = customer.subscription
        customer.cancel_subscription if stripe_sub and stripe_sub.status =~ (/trialing|active|past_due/)
        sub.update(active: false)
        sub
      else
        sub
      end
    end
  end
end
