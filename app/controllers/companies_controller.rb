class CompaniesController < ApplicationController
  before_filter :find_company, only: [:show]
  before_filter :get_and_check_company, only: [:edit, :update]

  def create
    @company = Company.new(company_params)
    @company.founded = Time.now
    if @company.save
      Notifier.new_company_confirmation(@company).deliver
      session[:company_id] = @company.id
      redirect_to company_purchase_options_path(:company_id => @company.id), notice: "You've just created a new company.  You will receive an email to verify your account in a moment."
    else
      flash[:error] = @company.clean_error_messages
      render 'sessions/sign_up'
    end
  end

  def show
    @job_listings = @company.job_listings
  end

  def edit
    @subscription = @company.subscription
  end

  def update
    @company.update(company_params)
    @company.password = params[:company][:password] if params[:company][:password] == params[:company][:password_confirmation]
    if @company.save
      redirect_to root_path, notice: "Info updated!"
    else
      flash[:error] = "Something went wrong"
      render :edit
    end
  end

  def validate_company
    @company = Company.find_by_email(params[:email])
    if @company
      @company.verified = true
      @company.save
      redirect_to root_path, notice: "You can now start searching for developers!"
    end
  end

  def get_users
    if company_signed_in?
      @users = User.all
    else
      redirect_to root_path
    end
  end

  private

  def find_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit!.merge(:founded => DateTime.new(params[:company][:founded].to_i))
  end
end
