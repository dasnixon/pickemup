require 'subscription_handler'
class SubscriptionsController < ApplicationController
  before_filter :find_and_check_company, except: [:listener]
  before_filter :get_credentials, only: [:edit, :update, :edit_card]

  def new
    @subscription = Subscription.new
    @clicked_option = params[:clicked_option]
  end

  def create
    @subscription = @company.build_subscription(subscription_params)
    if @subscription.save_with_payment
      redirect_to root_path, notice: 'Subscription created! Start by adding a job listing.'
    else
      flash[:error] = 'We had trouble adding your payment information, try again.'
      render :new
    end
  end

  def edit
  end

  def update
    check_for_cancellation
    check_for_changed_plan
    check_for_reactivation
    if @customer.save and @subscription.save_update
      redirect_to edit_company_path(id: @company.id), notice: 'Subscription information has been updated successfully.'
    else
      flash[:error] = 'We had trouble updating your payment information, try again.'
      render :edit
    end
  end

  def edit_card
    if params[:stripe_card_token].present?
      @customer.update_subscription(card: params[:stripe_card_token], plan: @subscription.plan)
      if @subscription.update(subscription_params)
        redirect_to edit_company_path(id: @company.id), notice: 'Successfully updated payment information.'
      else
        redirect_to edit_company_path(id: @company.id), notice: 'Unable to update payment information at this time.'
      end
    end
  end

  def listener
    if params.present?
      SubscriptionHandler.new(params)
      render :status => 200
    else
      render :status => 500
    end
  end

  def purchase_options
  end

  private

  def check_for_reactivation
    if params[:reactivate_subscription] == "true"
      @customer.update_subscription(plan: params[:plan])
      @subscription.update_plan(params[:plan])
      @subscription.active = true
    end
  end

  def check_for_cancellation
    if params[:cancel_subscription] == "true"
      @customer.cancel_subscription
      @subscription.active = false
    end
  end

  def check_for_changed_plan
    if params[:plan].try(:to_i) != @subscription.plan
      @customer.update_subscription(plan: params[:plan])
      @subscription.update_plan(params[:plan])
    end
  end

  def get_credentials
    @subscription = @company.subscription
    @customer = @subscription.retrieve_stripe_info if @subscription
    unless @subscription and @customer
      redirect_to edit_company_path(id: @company.id), alert: 'Unable to retrieve your stripe information at this time, try again.'
    end
  end

  def subscription_params
    params.permit(:company_id, :email, :plan, :stripe_card_token)
  end

  def find_and_check_company
    @company ||= Company.find(params[:company_id])
    check_invalid_permissions_company
  end
end

