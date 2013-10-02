class MessagesController < ApplicationController
  include MailboxerHub

  before_filter :find_mailbox_for, except: [:index]
  before_filter :get_box
  before_filter :validate_params, :lookup_info, only: [:new, :create]

  def index
    conversations_redirect
  end

  def show
    if @message = Message.find(params[:id]) and @conversation = @message.conversation
      if @conversation.is_participant?(@mailbox_for)
        specific_conversation_redirect and return
      end
    end
    conversations_redirect
  end

  def new
  end

  def create
    @receipt = @mailbox_for.send_message(@recipient, params[:body], params[:subject], params[:job_listing_id])
    if @receipt.errors.blank?
      @conversation  = @receipt.conversation
      flash[:notice] = t('mailboxer.sent')
      specific_conversation_redirect
    else
      render :new
    end
  end

  private

  def specific_conversation_redirect
    if user_signed_in?
      redirect_to user_conversation_path(user_id: current_user.id, id: @conversation.id, box: :sentbox)
    elsif company_signed_in?
      redirect_to company_conversation_path(company_id: current_company.id, id: @conversation.id, box: :sentbox)
    end
  end

  def sending_to_self?
    if user_signed_in?
      @recipient == current_user
    elsif company_signed_in?
      @recipient == current_company
    end
  end

  def already_messaged_for_job_listing
    notice = "You already have a conversation regarding this job listing."
    if user_signed_in?
      if conversation = current_user.mailbox.conversations.find_by(job_listing_id: @job_listing.id)
        box = :inbox
        if conversation.is_completely_trashed?(current_user)
          box = :trash
        elsif conversation.last_sender == current_user
          box = :sentbox
        end
        redirect_to user_conversation_path(user_id: current_user.id, id: conversation.id, box: box), notice: notice
      end
    elsif company_signed_in?
      if conversation = current_company.mailbox.conversations.find_by(job_listing_id: @job_listing.id)
        box = :inbox
        if conversation.is_completely_trashed?(current_company)
          box = :trash
        elsif conversation.last_sender == current_company
          box = :sentbox
        end
        redirect_to company_conversation_path(company_id: current_company.id, id: conversation.id, box: box), notice: notice
      end
    end
  end

  def validate_params
    unless params[:receiver] && params[:job_listing_id]
      conversations_redirect
    end
  end

  def lookup_info
    @job_listing = JobListing.find(params[:job_listing_id])
    @recipient = user_signed_in? ? Company.find(params[:receiver]) : User.find(params[:receiver])
    conversations_redirect('Missing a valid recipient or job listing') if invalid_message?
    already_messaged_for_job_listing
  end

  def invalid_message?
    @recipient.blank? || sending_to_self? || @job_listing.blank?
  end
end
