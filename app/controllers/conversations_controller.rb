class ConversationsController < ApplicationController
  include Concerns::MailboxerHub

  before_filter :find_mailbox_for, :check_invalid_permissions, :get_mailbox, :get_box
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
      @conversation.untrash(@mailbox_for)
    end

    if params[:reply_all].present?
      last_receipt = @mailbox.receipts_for(@conversation).last
      @receipt = @mailbox_for.reply_to_all(last_receipt, params[:body])
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
    @conversation.move_to_trash(@mailbox_for)
    if params[:location].present? and params[:location] == 'conversation'
      @box = 'trash' and conversations_redirect
    else
      conversations_redirect
    end
  end

  private

  def find_conversation
    @conversation = Conversation.find_by_id(params[:id])

    if @conversation.nil? or !@conversation.is_participant?(@mailbox_for)
      conversations_redirect
    end
  end
end
