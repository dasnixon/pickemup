class InterviewMail < ActionMailer::Base
  before_action :add_inline_attachment!

  default from: 'tom@pickemup.me'

  def send_interview_request_user(user, company, job_listing, interview)
    @user, @company, @job_listing, @interview = user, company, job_listing, interview
    mail(to: user.email, subject: "Pickemup - Interview Request from #{company.name}")
  end

  def send_interview_request_reminder(user, company, job_listing, interview)
    @user, @company, @job_listing, @interview = user, company, job_listing, interview
    mail(to: company.email, subject: "Pickemup - Interview Request to #{user.name}")
  end

  def user_requests_interview_reschedule(user, company, job_listing, interview)
    @user, @company, @job_listing, @interview = user, company, job_listing, interview
    mail(to: company.email, subject: "Pickemup - Interview Reschedule by #{user.name}")
  end

  def company_requests_interview_reschedule(user, company, job_listing, interview)
    @user, @company, @job_listing, @interview = user, company, job_listing, interview
    mail(to: user.email, subject: "Pickemup - Interview Reschedule by #{company.name}")
  end

  def user_interview_cancellation(user, company, job_listing)
    @user, @company, @job_listing = user, company, job_listing
    mail(to: company.email, subject: "Pickemup - Interview Cancellation by #{user.name}")
  end

  def company_interview_cancellation(user, company, job_listing)
    @user, @company, @job_listing = user, company, job_listing
    mail(to: user.email, subject: "Pickemup - Interview Cancellation by #{company.name}")
  end

  def company_accepts_user(user, company, job_listing)
    @user, @company, @job_listing = user, company, job_listing
    mail(to: user.email, subject: "Pickemup - Congratulations! Hiring Request Sent to #{user.name}")
  end

  def notify_user_rejection(user, company, job_listing)
    @user, @company, @job_listing = user, company, job_listing
    mail(to: user.email, subject: "Pickemup - Sorry. Hiring Rejection by #{company.name}")
  end

  def notify_user_hireable(user, company, job_listing)
    @user, @company, @job_listing = user, company, job_listing
    mail(to: user.email, subject: "Pickemup - Congratuations! Hiring Request by #{company.name}")
  end

  def send_user_scheduled_time(user, company, job_listing, interview)
    @user, @company, @job_listing, @interview = user, company, job_listing, interview
    mail(to: user.email, subject: "Pickemup - Interview Schedule Confirmation with #{company.name}")
  end

  def send_company_scheduled_time(user, company, job_listing, interview)
    @user, @company, @job_listing, @interview = user, company, job_listing, interview
    mail(to: company.email, subject: "Pickemup - Interview Schedule Confirmation with #{user.name}")
  end

  private

  def add_inline_attachment!
    attachments.inline['logo.png'] = File.read("#{Rails.root.to_s}/app/assets/images/logo.png")
  end
end
