class Notifier < ActionMailer::Base
  default from: "tom@pickemup.me"

  def new_company_confirmation(company)
    @company = company
    mail(:to => @company.email,
         :subject => "Welcome to Pickemup!")
  end

  def new_user_welcome(user_email)
    @user_email = user_email
    mail(:to => @user_email,
         :subject => "Welcome to Pickemup!")
  end

  def contact_us(contact)
    @contact = contact
    mail(from: contact.email_address_with_name,
         to: "tom@pickemup.me; chris@pickemup.me",
         subject: "Contact Form Request - #{@contact.name}"
        )
  end
end
