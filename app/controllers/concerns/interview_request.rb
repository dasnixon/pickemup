module InterviewRequest
  extend ActiveSupport::Concern

  DATE_PARAMS = ['year', 'month', 'day', 'hour', 'minute']

  private

  def render_by_session
    if company_signed_in?
      render :setup_company_reschedule and return
    elsif user_signed_in?
      render :setup_user_reschedule and return
    end
  end

  def company_interview_params
    params.require(:interview).permit(:description, :duration, :company_id, :user_id, :job_listing_id, :location)
  end

  def valid_interview_params_for_company?
    params[:date].present? and
      ((params[:date].keys & DATE_PARAMS).length == DATE_PARAMS.length) and
      (params[:date].values.compact.length == DATE_PARAMS.length) and
      params[:interview].present? and
      params[:interview][:duration].present? and
      params[:interview][:description].present? and
      params[:interview][:location].present?
  end

  def creating_message?
    params[:controller] == 'messages' and params[:action] == 'create'
  end
end
