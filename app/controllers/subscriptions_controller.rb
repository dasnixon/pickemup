require 'subscription_handler'
class SubscriptionsController < ApplicationController
  before_filter :find_company, except: [:listener]
  before_filter :get_credentials, only: [:edit, :update, :edit_card]

  def new
    @subscription = Subscription.new
    @clicked_option = params[:clicked_option]
  end

  def create
    @subscription = @company.build_subscription(subscription_params)
    if @subscription.save_with_payment
      redirect_to root_path, notice: "Subscription created! Start adding a job listing."
    else
      flash[:error] = "Something went wrong"
      render :new
    end
  end

  def edit
  end

  def update
    check_for_cancellation
    check_for_changed_plan
    check_for_reactivation
    if @customer.save && @subscription.save_update
      flash[:success] = "Subscription info updated!"
      redirect_to edit_company_path(@subscription.company_id) #change path
    else
      flash[:error] = "Something went wrong"
      render :edit
    end
  end

  def edit_card
    if params[:stripe_card_token].present?
      @customer.update_subscription(card: params[:stripe_card_token], plan: @subscription.plan)
      if @subscription.update(subscription_params)
        redirect_to edit_company_path(@subscription.company_id), notice: 'Successfully updated payment information.'
      else
        redirect_to edit_company_path(@subscription.company_id), notice: 'Unable to update payment information at this time.'
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
      new_plan = params[:plan]
      @customer.update_subscription(:plan => new_plan)
      @subscription.update_plan(new_plan)
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
    if params[:plan] != @subscription.plan
      @customer.update_subscription(:plan => params[:plan])
      @subscription.update_plan(params[:plan])
    end
  end

  def get_credentials
    @subscription = @company.subscription
    @customer = Stripe::Customer.retrieve(@subscription.stripe_customer_token)
  end

  def subscription_params
    params.permit(:company_id, :email, :plan, :stripe_card_token)
  end

  def find_company
    @company ||= Company.find(params[:company_id])
    check_invalid_permissions_company
  end
end

