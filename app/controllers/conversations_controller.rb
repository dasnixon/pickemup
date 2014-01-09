class ConversationsController < ApplicationController
  PER_PAGE = 5

  include MailboxerHub

  before_filter :find_mailbox_for, :get_mailbox, :get_box
  before_filter :find_conversation, only: [:show, :update, :destroy, :untrash]
  after_filter :destroy_interview, only: [:destroy]

  def index
    if @box.eql? 'inbox'
      conversations = @mailbox.inbox
    elsif @box.eql? 'sentbox'
      conversations = @mailbox.sentbox
    else
      conversations = @mailbox.trash
    end
    @conversations = conversations.select { |conv| JobListing.exists?(id: conv.job_listing_id) }.paginate(page: params[:page], per_page: PER_PAGE)
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
      @box = 'trash' and conversations_redirect('Successfully removed conversation')
    else
      conversations_redirect('Successfully removed conversation')
    end
  end

  def untrash
    @conversation.untrash(@mailbox_for)
    @box = 'inbox' and conversations_redirect('Successfully untrashed the conversation')
  end

  private

  def find_conversation
    @conversation = Conversation.find(params[:id])
    if !JobListing.exists?(id: @conversation.job_listing_id) or @conversation.blank? or !@conversation.is_participant?(@mailbox_for)
      conversations_redirect('Unable to find conversation or the job listing no longer exists, sorry.')
    end
  end

  def destroy_interview
    user, company = nil, nil
    @conversation.participants.each do |participant|
      user = participant if participant.is_a?(User)
      company = participant if participant.is_a?(Company)
    end
    interview = Interview.find_by(job_listing_id: @conversation.job_listing_id, user_id: user.id, company_id: company.id)
    if interview.present?
      if user_signed_in?
        interview.send_company_cancellation_and_destroy
      elsif company_signed_in?
        interview.send_user_cancellation_and_destroy
      end
    end
  end
end
