class MessagesController < ApplicationController
  include Concerns::MailboxerHub

  before_filter :find_mailbox_for, :get_mailbox, :get_box
  before_filter :validate_params, only: [:new, :create]

  def index
    conversations_redirect
  end

  def show
    if @message = Message.find_by_id(params[:id]) and @conversation = @message.conversation
      if @conversation.is_participant?(@mailbox_for)
        specific_conversation_redirect
      return
      end
    end
    conversations_redirect
  end

  def new
    @job_listing = JobListing.find(params[:job_listing_id])
    if user_signed_in?
      @recipient = Company.find(params[:receiver])
    elsif company_signed_in?
      @recipient = User.find(params[:receiver])
    end
    return if @recipient.nil?
    @recipient = nil if sending_to_self?
  end

  def create
    @job_listing = JobListing.find(params[:job_listing_id])
    @recipient = user_signed_in? ? Company.find(params[:receiver]) : User.find(params[:receiver])

    @receipt = @mailbox_for.send_message(@recipients, params[:body], params[:subject], params[:job_listing_id])
    if (@receipt.errors.blank?)
      @conversation = @receipt.conversation
      flash[:notice]= t('mailboxer.sent')
      specific_conversation_redirect
    else
      render action: :new
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

  def validate_params
    unless params[:receiver] && params[:job_listing_id]
      conversations_redirect
    end
  end
end
