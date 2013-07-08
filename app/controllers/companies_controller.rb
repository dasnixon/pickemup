class CompaniesController < ApplicationController
  before_filter :find_company, :except => [:new, :create]

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    unless params[:company][:email].blank? || params[:company][:password].blank? || params[:company][:password_confirmation].blank?
      if @company.save
        session[:company_id] = @company.id
        redirect_to root_path, notice: "You've just created a new company!"
      else
        @company.errors.messages.each { |error, message| flash[:error] = message.join(', ') }
        render :new
      end
    else
      flash[:error] = "Email and Password are required."
      render :new
    end
  end

  def show
  end

  def edit
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
    params.require(:company).permit(:email, :password, :password_confirmation)
  end

  def company_info_params
    params.require(:company).permit(:email, :name, :description,
                                    :website, :industry, :num_employees, :public).merge(:founded => DateTime.new(params[:company][:founded].to_i))
  end
end
