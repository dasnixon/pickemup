require 'stripe'
class SubscriptionHandler
  def initialize(params)
    @params = params
    sort_issue
  end

  def sort_issue
    case @params[:type]
    when 'customer.subscription.deleted'
      deactivate_subscription
    end
  end

  private

  def deactivate_subscription
    if Subscription.find_by_stripe_customer_token(@params[:data][:object][:customer])
      subscription = Subscription.find_by_stripe_customer_token(@params[:data][:object][:customer])
      subscription.active = false
      subscription.save
      #email customer that account has been deactivated
    end
  end
end

