module MailboxerHub
  extend ActiveSupport::Concern

  private

  def get_mailbox
    @mailbox = @mailbox_for.mailbox
  end

  def get_box
    if params[:box].blank? or !["inbox","sentbox","trash"].include?(params[:box])
      @box = params[:box] = 'inbox'
    else
      @box = params[:box]
    end
  end

  def find_mailbox_for
    if params[:user_id]
      if user_signed_in? and params[:user_id] == current_user.id
        @mailbox_for = @user = current_user
        check_invalid_permissions_user
      else
        redirect_to root_path, alert: 'You do not have permissions to view this page'
      end
    elsif params[:company_id]
      if company_signed_in? and params[:company_id] == current_company.id
        @mailbox_for = @company = current_company
        check_invalid_permissions_company
      else
        redirect_to root_path, alert: 'You do not have permissions to view this page'
      end
    else
      redirect_to root_path, notice: 'Unable to find your mailbox.'
    end
  end

  def conversations_redirect(message=nil)
    if params[:user_id]
      redirect_to(user_conversations_path(box: @box), notice: message)
    elsif params[:company_id]
      redirect_to(company_conversations_path(box: @box), notice: message)
    else
      redirect_to root_path, error: 'Unable to find your conversation.'
    end
  end
end
