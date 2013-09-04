class Notifier < ActionMailer::Base
  default from: "pickemupteam@gmail.com"

  def new_company_confirmation(company)
    #@company = company
    #mail(:to => @company.email,
    #     :subject => "Please verify your Pickemup subscription for #{@company.name}")
  end

  def contact_us(contact)
    @contact = contact
    mail(from: contact.email_address_with_name,
         to: "Pickemup Team <pickemupteam@gmail.com>",
         subject: "Contact Form Request - #{@contact.name}"
        )
  end
end
