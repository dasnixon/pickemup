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
#

class Interview < ActiveRecord::Base
  validates :request_date, :status, presence: true
  validate :already_has_interview
  validate :future_request

  after_create :send_interview_request

  # STATES
  # 1. :pending
  # 2. :in_progress
  # 3. :hireable
  # 4. :rejected
  # 5. :reschedule

  state_machine initial: :pending do
    after_transition :pending => :in_progress do |interview, transition|
      interview.send_scheduled_time
    end
    after_transition any => :hireable do |interview, transition|
      interview.hireable = true
      interview.save
    end
    after_transition any => :rejected do |interview, transition|
      interview.hireable = false
      interview.save
    end
    after_transition any => :reschedule do |interview, transition|
      interview.send_reschedule_request
    end
    event :schedule do
      transition :pending => :in_progress
    end
    event :reject do
      transition any => :rejected
    end
    event :hire do
      transition any => :hireable
    end
  end

  def send_interview_request
    #send email to parties for interview
  end

  def send_scheduled_time

  end

  def send_reschedule_request

  end

  private

  def future_request
    return if self.errors.any?
    if self.request_date.present? and (self.request_date < Time.now)
      self.errors.add(:request_date, "The date scheduled for the interview must take place after #{Time.now}.")
    end
  end

  def already_has_interview
    return if self.errors.any?
    if Interview.where(company_id: self.company_id, user_id: self.user_id, job_listing_id: self.job_listing_id).present?
      self.errors.add(:base, 'You already have an interview setup, check your interview history.')
    end
  end
end
