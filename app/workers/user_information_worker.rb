class UserInformationWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    return if user.blank?
    user.update_resume
  end
end
