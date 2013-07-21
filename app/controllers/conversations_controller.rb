class ConversationsController < ApplicationController
  before_filter :find_user, :check_invalid_permissions, :get_mailbox, :get_box
  before_filter :find_conversation, only: [:show, :update, :destroy]

  def index
    if @box.eql? "inbox"
      @conversations = @mailbox.inbox
    elsif @box.eql? "sentbox"
      @conversations = @mailbox.sentbox
    else
      @conversations = @mailbox.trash
    end
  end

  def show
    if @box.eql? 'trash'
      @receipts = @mailbox.receipts_for(@conversation).trash
    else
      @receipts = @mailbox.receipts_for(@conversation).not_trash
    end
    @receipts.mark_as_read
  end

  def update
    if params[:untrash].present?
      @conversation.untrash(@user)
    end

    if params[:reply_all].present?
      last_receipt = @mailbox.receipts_for(@conversation).last
      @receipt = @user.reply_to_all(last_receipt, params[:body])
    end

    if @box.eql? 'trash'
      @receipts = @mailbox.receipts_for(@conversation).trash
    else
      @receipts = @mailbox.receipts_for(@conversation).not_trash
    end
    redirect_to action: :show
    @receipts.mark_as_read
  end

  def destroy
    @conversation.move_to_trash(@user)
    if params[:location].present? and params[:location] == 'conversation'
      redirect_to user_conversations_path(box: :trash)
    else
      redirect_to user_conversations_path(box: @box)
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

  def find_conversation
    @conversation = Conversation.find_by_id(params[:id])

    if @conversation.nil? or !@conversation.is_participant?(@user)
      redirect_to conversations_path(box: @box) and return
    end
  end

  def find_user
    @user = User.find(params[:user_id])
  end
end
