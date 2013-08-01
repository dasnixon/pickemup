class StoreUserProfileImage
  include Sidekiq::Worker

  def perform(user_id, image_url)
    return unless user_id.present? && image_url.present?
    user = User.find(user_id)
    return if user.blank?
    user.set_user_image(image_url)
  end
end
