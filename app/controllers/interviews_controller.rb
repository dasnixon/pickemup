class InterviewsController < ApplicationController
  include InterviewRequest

  before_filter :check_company_signed_in, only: [:new, :create, :setup_company_reschedule, :company_reschedule, :accept_candidate, :reject_candidate]
  before_filter :initialize_new_interview_for_company, only: [:new, :create]
  before_filter :setup, except: [:new, :create, :events, :index]
  before_filter :check_valid_company_interview_setup, only: [:new, :create]
  before_filter :check_valid_interview_for_company, only: [:setup_company_reschedule, :company_reschedule, :accept_candidate, :reject_candidate]
  before_filter :check_user_signed_in, :check_valid_interview_for_user, only: [:setup_user_reschedule, :user_reschedule]
  before_filter :check_valid_interview, except: [:new, :create, :events, :index]
  respond_to :json, :html

  def index
    if user_signed_in?
      if params[:type] == 'upcoming'
        @interviews = current_user.upcoming_interviews
      elsif params[:type] == 'past'
        @interviews = current_user.past_interviews
      else
        @interviews = current_user.interviews
      end
    elsif company_signed_in?
      if params[:type] == 'upcoming'
        @interviews = current_company.upcoming_interviews
      elsif params[:type] == 'past'
        @interviews = current_company.past_interviews
      else
        @interviews = current_company.interviews
      end
    else
      redirect_to root_path, notice: 'You do not have permissions to view this page.'
    end
  end

  def show
  end

  def new
    @interview = Interview.new(company_id: current_company.id, user_id: @user.id, job_listing_id: @job_listing.id)
  end

  def create
    if valid_interview_params_for_company?
      @interview = Interview.new(company_interview_params.merge(company_id: current_company.id, user_id: @user.id, job_listing_id: @job_listing.id))
      begin
        @interview.request_date = Time.new(params[:date][:year], params[:date][:month], params[:date][:day], params[:date][:hour], params[:date][:minute])
        if @interview.save
          company_conversation_redirect('Successfully scheduled the interview.')
        else
          flash[:error] = 'The interview you are trying to setup is invalid, make sure there is a duration, description, it has a valid date, and the interview takes place in the future.'
          render :new
        end
      rescue Exception
        flash[:error] = 'Input a valid interview date and time please.'
        render :new
      end
    else
      flash[:error] = 'The interview you are trying to setup is invalid, make sure there is a duration, description, it has a valid date, and the interview takes place in the future.'
      render :new
    end
  end

  def user_cancel
    @interview.send_company_cancellation_and_destroy
    user_conversation_redirect("Successfully cancelled the interview, we will contact #{@company.name} to let them know you no longer wish to interview.")
  end

  def company_cancel
    @interview.send_user_cancellation_and_destroy
    company_conversation_redirect("Successfully cancelled the interview, we will contact #{@user.name} to let them know you no longer wish to interview.")
  end

  def setup_user_reschedule
  end

  def user_reschedule
    begin
      time = Time.new(params[:date][:year], params[:date][:month], params[:date][:day], params[:date][:hour], params[:date][:minute])
      if @interview.update({request_date: time, rescheduled_by: 'user'})
        @interview.reschedule
        user_conversation_redirect("Successfully rescheduled the interview, we will contact #{@company.name} to verify the new time will work.")
      else
        flash[:error] = 'The interview you are trying to setup is invalid, make sure there is a duration, description, it has a valid date, and the interview takes place in the future.'
        render_by_session
      end
    rescue Exception
      flash[:error] = 'Input a valid interview date and time please.'
      render_by_session
    end
  end

  def setup_company_reschedule
  end

  def company_reschedule
    begin
      time = Time.new(params[:date][:year], params[:date][:month], params[:date][:day], params[:date][:hour], params[:date][:minute])
      if @interview.update(company_interview_params.merge(request_date: time, rescheduled_by: 'company'))
        @interview.reschedule
        company_conversation_redirect("Successfully rescheduled the interview, we will contact #{@user.name} to verify the newly scheduled time will work.")
      else
        flash[:error] = 'The interview you are trying to setup is invalid, make sure there is a duration, description, it has a valid date, and the interview takes place in the future.'
        render_by_session
      end
    rescue Exception
      flash[:error] = 'Input a valid interview date and time please.'
      render_by_session
    end
  end

  def accept_candidate
    @interview.hire
    company_conversation_redirect("Excellent, we will contact #{@user.name} and inform them that you would like to speak about hiring.")
  end

  def reject_candidate
    @interview.reject
    company_conversation_redirect("Sorry to hear you have rejected #{@user.name}. We will inform them that they have not been accepted for the job listing.")
  end

  def events
    if user_signed_in?
      respond_with current_user.get_scheduled_interviews
    elsif company_signed_in?
      respond_with current_company.get_scheduled_interviews
    else
      respond_with []
    end
  end

  def accept_scheduled
    if company_signed_in?
      check_valid_interview_for_company
      if @interview.valid_for_acceptance_by_company?
        @interview.schedule
        company_conversation_redirect("You have accepted the interview scheduled with #{@user.name}. We will send a verification email soon.")
      else
        company_conversation_redirect("You are unable to accept the interview scheduled, because we are still awaiting for #{@user.name} to accept.")
      end
    elsif user_signed_in?
      check_valid_interview_for_user
      if @interview.valid_for_acceptance_by_user?
        @interview.schedule
        user_conversation_redirect("You have accepted the interview scheduled with #{@company.name}. We will send a verification email soon.")
      else
        user_conversation_redirect("You are unable to accept the interview scheduled, because we are still awaiting for #{@company.name} to accept.")
      end
    else
      redirect_to root_path, notice: 'Invalid permissions.'
    end
  end

  private

  def initialize_new_interview_for_company
    @user        = User.find(params[:user_id])
    @job_listing = JobListing.find(params[:job_listing_id])
    @company     = current_company
  end

  def setup
    @interview   = Interview.find(params[:id])
    @user        = current_user || User.find(@interview.user_id)
    @job_listing = JobListing.find(@interview.job_listing_id)
    @company     = current_company || Company.find(@interview.company_id)
  end

  def user_conversation_redirect(notice)
    conversation = current_user.mailbox.conversations.find_by(job_listing_id: @interview.job_listing_id)
    redirect_to user_conversation_path(user_id: current_user.id, id: conversation.id), notice: notice
  end

  def company_conversation_redirect(notice)
    conversation = current_company.mailbox.conversations.find_by(job_listing_id: @interview.job_listing_id)
    redirect_to company_conversation_path(company_id: current_company.id, id: conversation.id), notice: notice
  end

  def has_proper_params?
    params[:user_id].present? and params[:company_id].present? and params[:job_listing_id].present?
  end

  def check_valid_interview
    if @interview.rejected?
      if company_signed_in?
        company_conversation_redirect("You already have rejected #{@user.name} in a previous interview.")
      elsif user_signed_in?
        user_conversation_redirect("You already have been rejected by #{@company.name} in a previous interview. Sorry.")
      end
    end
  end

  ########### COMPANY interview checks (signed in, valid interview, valid params, etc.) ############
  def check_company_signed_in
    redirect_to root_path, notice: 'Invalid permissions.' and return unless company_signed_in?
  end

  def check_valid_interview_for_company
    redirect_to root_path, notice: 'Invalid permissions.' and return unless @interview.company_id == current_company.id
  end

  def check_valid_company_interview_setup
    params[:company_id] ||= current_company.id
    redirect_to root_path, notice: 'Invalid permissions.' and return unless has_proper_params? and params[:company_id] == current_company.id
  end

  ########### USER interview checks (signed in, valid interview, valid params, etc.) ############
  def check_user_signed_in
    redirect_to root_path, notice: 'Invalid permissions.' and return unless user_signed_in?
  end

  def check_valid_interview_for_user
    redirect_to root_path, notice: 'Invalid permissions.' and return unless @interview.user_id == current_user.id
  end
end
