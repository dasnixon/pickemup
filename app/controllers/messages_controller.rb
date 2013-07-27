class MessagesController < ApplicationController
  include Concerns::MailboxerHub
  before_filter :find_mailbox_for, :check_invalid_permissions, :get_mailbox, :get_box

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
    if params[:receiver].present?
      if user_signed_in?
        @recipient = Company.find(params[:receiver])
      elsif company_signed_in?
        @recipient = User.find(params[:receiver])
      end
      return if @recipient.nil?
      @recipient = nil if sending_to_self?
    end
  end

  def create
    @recipients =
      if params[:_recipients].present?
        @recipients = params[:_recipients].split(',').map{ |r| (user_signed_in? ? Company.find(r) : User.find(r)) }
      else
        []
      end

    @receipt = @mailbox_for.send_message(@recipients, params[:body], params[:subject])
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
end
