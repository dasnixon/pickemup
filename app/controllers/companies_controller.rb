class CompaniesController < ApplicationController
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

  private

  def company_params
    params.require(:company).permit(:email, :password, :password_confirmation)
  end
end
