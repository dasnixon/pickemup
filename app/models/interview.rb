# == Schema Information
#
# Table name: interviews
#
#  id             :uuid             not null, primary key
#  status         :string(255)      default("pending")
#  hireable       :boolean
#  request_date   :datetime
#  job_listing_id :uuid
#  company_id     :uuid
#  user_id        :uuid
#  created_at     :datetime
#  updated_at     :datetime
#  duration       :integer
#  description    :text
#  location       :string(255)
#  rescheduled_by :string(255)
#

class Interview < ActiveRecord::Base
  validates :request_date, :status, :company_id, :user_id, :job_listing_id, :description, :location, presence: true
  validates :duration, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 13 }
  validates :user_id, uniqueness: { scope: [:company_id, :job_listing_id] }
  validates :rescheduled_by, inclusion: { in: %w(user company) }, allow_blank: true
  validate :future_request, :no_impeding_interview

  after_create :send_interview_request

  belongs_to :company
  belongs_to :user
  belongs_to :job_listing

  # STATES
  # 1. :pending
  # 2. :in_progress
  # 3. :hireable
  # 4. :rejected
  # 5. :reschedule

  state_machine :status, initial: :pending do
    after_transition any => :in_progress, do: :send_scheduled_time
    after_transition any => :hireable, do: :hire
    after_transition any => :rejected, do: :reject
    after_transition any => :reschedule, do: :send_reschedule_request

    event :schedule do
      transition any => :in_progress
    end
    event :reschedule do
      transition any => :reschedule
    end
    event :reject do
      transition any => :rejected
    end
    event :hire do
      transition any => :hireable
    end

    state :reschedule, :in_progress do
      validate :valid_for_acceptance
    end
  end

  def hire
    self.hireable = true
    self.send_hiring_emails
  end

  def reject
    self.hireable = false
    self.send_rejection_email
  end

  def pending?
    self.status == 'pending'
  end

  def rescheduled?
    self.status == 'reschedule'
  end

  def rejected?
    self.status == 'rejected'
  end

  def in_progress?
    self.status == 'in_progress'
  end

  def awaiting_response?
    (self.pending? or self.rescheduled?) and !self.rejected? and !self.completed_state?
  end

  def completed_state?
    self.in_progress? and passed_request_date?
  end

  def passed_request_date?
    Time.now.utc > self.request_date
  end

  def valid_for_acceptance_by_company?
    self.awaiting_response? and self.user_requested_reschedule?
  end

  def valid_for_acceptance_by_user?
    self.awaiting_response? and (self.rescheduled_by.nil? || self.company_requested_reschedule?)
  end

  def user_requested_reschedule?
    self.rescheduled_by == 'user'
  end

  def company_requested_reschedule?
    self.rescheduled_by == 'company'
  end

  def accepted?
    self.in_progress? and !passed_request_date?
  end

  def accepted_by_user?
    self.accepted? and (self.rescheduled_by.nil? || self.company_requested_reschedule?)
  end

  def accepted_by_company?
    self.accepted? and self.user_requested_reschedule?
  end

  def enough_time_to_schedule?
    (self.request_date - Time.now) > 1.hour
  end

  ######## MAILING ########

  def send_rejection_email
    InterviewMail.notify_user_rejection(self.user, self.company, self.job_listing).deliver
  end

  def send_hiring_emails
    InterviewMail.company_accepts_user(self.user, self.company, self.job_listing).deliver
    InterviewMail.notify_user_hireable(self.user, self.company, self.job_listing).deliver
  end

  def send_interview_request
    InterviewMail.send_interview_request_user(self.user, self.company, self.job_listing, self).deliver
    InterviewMail.send_interview_request_reminder(self.user, self.company, self.job_listing, self).deliver
  end

  def send_scheduled_time
    InterviewMail.send_user_scheduled_time(self.user, self.company, self.job_listing, self).deliver
    InterviewMail.send_company_scheduled_time(self.user, self.company, self.job_listing, self).deliver
  end

  def send_company_cancellation_and_destroy
    self.destroy
    InterviewMail.user_interview_cancellation(self.user, self.company, self.job_listing).deliver
  end

  def send_user_cancellation_and_destroy
    self.destroy
    InterviewMail.company_interview_cancellation(self.user, self.company, self.job_listing).deliver
  end

  def send_reschedule_request
    if self.company_requested_reschedule?
      InterviewMail.company_requests_interview_reschedule(self.user, self.company, self.job_listing, self).deliver
    elsif self.user_requested_reschedule?
      InterviewMail.user_requests_interview_reschedule(self.user, self.company, self.job_listing, self).deliver
    end
  end

  private

  def future_request
    return if self.errors.any? or !self.request_date_changed?
    if self.request_date.present? and passed_request_date? and enough_time_to_schedule?
      self.errors.add(:request_date, "The date scheduled for the interview must take place after #{Time.now} and needs to take place at least an hour in advance for notice.")
    end
  end

  def no_impeding_interview
    return if self.errors.any? or !self.request_date_changed?
    if impedes_user_schedule? or impedes_company_schedule?
      self.errors.add(:base, 'There is a conflict in schedules. Try again please.')
    end
  end

  def impedes_user_schedule?
    Interview.where(user_id: self.user_id, request_date: (self.request_date - 15.minutes)..(self.request_date + duration.hours + 15.minutes)).reject(&:self).present?
  end

  def impedes_company_schedule?
    Interview.where(company_id: self.company_id, request_date: (self.request_date - 15.minutes)..(self.request_date + duration.hours + 15.minutes)).reject(&:self).present?
  end

  def valid_for_acceptance
    if self.passed_request_date?
      self.errors.add(:base, 'Unable to accept this interview because it takes place in the past. Please reschedule the interview.')
    end
  end
end
