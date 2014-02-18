module InterviewsHelper
  def company_for_interview(interview)
    Company.find(interview.company_id)
  end

  def user_for_interview(interview)
    User.find(interview.user_id)
  end

  def job_listing_for_interview(interview)
    JobListing.find(interview.job_listing_id)
  end

  def label_status(interview, label_for)
    case interview.status
      when 'rejected'
        return 'Rejected'
      when 'hireable'
        return 'Accepted'
    end
    label_for == 'user' ? user_label_status(interview) : company_label_status(interview)
  end

  def user_label_status(interview)
    case interview.status
      when 'pending'
        if interview.passed_request_date?
          'You did not respond'
        else
          'Awaiting your response'
        end
      when 'in_progress'
        if interview.passed_request_date?
          'Completed - awaiting company action'
        else
          'Upcoming'
        end
      when 'reschedule'
        if interview.company_requested_reschedule?
          if interview.passed_request_date?
            'You never responded'
          else
            'Awaiting your response'
          end
        else
          if interview.passed_request_date?
            'Company never responded'
          else
            'Awaiting company response'
          end
        end
    end
  end

  def company_label_status(interview)
    case interview.status
      when 'pending'
        if interview.passed_request_date?
          'Unresponsive to Request'
        else
          'Awaiting Response'
        end
      when 'in_progress'
        if interview.passed_request_date?
          'Completed - awaiting your response'
        else
          'Upcoming'
        end
      when 'reschedule'
        if interview.user_requested_reschedule?
          if interview.passed_request_date?
            'You never responded'
          else
            'Awaiting your response'
          end
        else
          if interview.passed_request_date?
            'User never responded'
          else
            'Awaiting user response'
          end
        end
    end
  end


end
