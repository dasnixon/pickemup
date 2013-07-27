module Concerns
  module MailboxerHub
    extend ActiveSupport::Concern

    private

    def get_mailbox
      @mailbox = @mailbox_for.mailbox
    end

    def get_box
      if params[:box].blank? or !["inbox","sentbox","trash"].include?(params[:box])
        @box = params[:box] = 'inbox'
        return
      end
      @box = params[:box]
    end

    def find_mailbox_for
      if params[:user_id]
        @mailbox_for = @user = User.find(params[:user_id])
      elsif params[:company_id]
        @mailbox_for = @company = Company.find(params[:company_id])
      end
    end

    def conversations_redirect
      if params[:user_id]
        redirect_to user_conversations_path(box: @box) and return
      elsif params[:company_id]
        redirect_to company_conversations_path(box: @box) and return
      end
    end
  end
end
