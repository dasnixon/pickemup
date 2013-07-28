class CompaniesController < ApplicationController
  before_filter :find_company, only: [:show]
  before_filter :get_and_check_company, only: [:edit, :update]

  def create
    @company = Company.new(company_params)
    if @company.save
      session[:company_id] = @company.id
      redirect_to new_company_subscription_path(company_id: @company.id), notice: "You've just created a new company!"
    else
      redirect_to sign_up_path, error: @company.errors.messages
    end
  end

  def show
  end

  def edit
    @subscription = @company.subscription
  end

  def update
    @company.update_attributes(company_info_params)
    #TODO add JS validation of password/password_confirmation fields
    @company.password = params[:company][:password] if params[:company][:password] == params[:company][:password_confirmation]
    if @company.save
      redirect_to root_path, notice: "Info updated!"
    else
      flash[:error] = "Something went wrong"
      render :edit
    end
  end

  private

  def find_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name, :email, :password, :password_confirmation)
  end

  def company_info_params
    params.require(:company).permit(:email, :name, :description,
                                    :website, :industry, :num_employees, :public).merge(:founded => DateTime.new(params[:company][:founded].to_i))
  end
end
