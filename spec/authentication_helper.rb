module AuthenticationHelper
  def user_login(user)
    session[:user_id] = user.id
  end

  def user_logout
    session[:user_id] = nil
  end

  def company_login(company)
    session[:company_id] = company.id
  end

  def company_logout
    session[:company_id] = nil
  end
end
