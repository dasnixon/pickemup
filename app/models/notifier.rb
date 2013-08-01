class Notifier < ActionMailer::Base
  default :from => "pickemupteam@gmail.com"

  def new_company_confirmation(company)
    #@company = company
    #mail(:to => @company.email,
    #     :subject => "Please verify your Pickemup subscription for #{@company.name}")
  end
end
