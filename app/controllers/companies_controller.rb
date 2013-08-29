class CompaniesController < ApplicationController
  before_filter :find_company, only: [:show]
  before_filter :find_by_email, :check_invalid_permissions_company, only: [:validate_company]
  before_filter :get_and_check_company, only: [:edit, :update]
  before_filter :cleanup_password_info, only: [:update]

  def create
    @company = Company.new(company_params)
    if @company.save_with_tracking_info(request)
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
    if @company.update(company_params)
      redirect_to company_path(id: @company.id), notice: 'Info updated!'
    else
      @subscription = @company.subscription
      flash[:error] = 'Unable to update your company information'
      render :edit
    end
  end

  def validate_company
    @company.set_verified
    redirect_to root_path, notice: "You can now start searching for developers!"
  end

  private

  def find_by_email
    @company = Company.find_by(email: params[:email])
  end

  def find_company
    @company = Company.find(params[:id])
  end

  def company_params
    founded = params[:company][:founded].present? ? params[:company][:founded] : Time.now
    params.require(:company).permit(:name, :email, :description, :website, :industry, :description, :size_definition,
      :num_employees, :public, :founded, :logo, :password, :password_confirmation).merge(founded: founded)
  end

  def cleanup_password_info
    unless params[:company][:password].present? and params[:company][:password_confirmation].present?
      [:password, :password_confirmation].each { |key| params[:company].delete(key) }
    end
  end
end
