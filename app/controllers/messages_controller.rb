class MessagesController < ApplicationController
  before_filter :find_user, :check_invalid_permissions, :get_mailbox, :get_box

  def index
    redirect_to user_conversations_path(box: @box)
  end

  def show
    if @message = Message.find_by_id(params[:id]) and @conversation = @message.conversation
      if @conversation.is_participant?(@user)
        redirect_to user_conversation_path(user_id: @user.id, id: @conversation.id, box: @box, anchor: "message_" + @message.id.to_s)
      return
      end
    end
    redirect_to user_conversations_path(box: @box)
  end

  def new
    if params[:receiver].present?
      @recipient = User.find(params[:receiver])
      return if @recipient.nil?
      @recipient = nil if @recipient == current_user
    end
  end

  def create
    @recipients =
      if params[:_recipients].present?
        @recipients = params[:_recipients].split(',').map{ |r| User.find(r) }
      else
        []
      end

    @receipt = @user.send_message(@recipients, params[:body], params[:subject])
    if (@receipt.errors.blank?)
      @conversation = @receipt.conversation
      flash[:notice]= t('mailboxer.sent')
      redirect_to user_conversation_path(user_id: @user.id, id: @conversation.id, box: :sentbox)
    else
      render action: :new
    end
  end

  private

  def get_mailbox
    @mailbox = @user.mailbox
  end

  def get_box
    if params[:box].blank? or !["inbox","sentbox","trash"].include?(params[:box])
      @box = params[:box] = 'inbox'
      return
    end
    @box = params[:box]
  end

  def find_user
    @user = User.find(params[:user_id])
  end
end
