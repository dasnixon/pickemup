module LinkedinLogin
  extend ActiveSupport::Concern

  def set_user_linkedin_information(auth)
    self.newly_created = true
    unless self.main_provider.present?
      self.main_provider = 'linkedin'
      self.set_attributes_from_linkedin(auth)
    end
    self.build_linkedin.from_omniauth(auth)
  end

  def check_and_remove_existing_linkedin(uid)
    user = User.where(linkedin_uid: uid)
    user.first.destroy if user.present? && self != user.first
  end

  def update_linkedin_information(auth)
    self.linkedin.from_omniauth(auth)
    self.set_attributes_from_linkedin(auth)
    UserInformationWorker.perform_async(self.id) #this will call the update_resume method
  end

  #set attributes from the linkedin auth information on the user
  def set_attributes_from_linkedin(auth)
    info             = auth.info
    extra_info       = auth.extra.raw_info
    self.name        = info.name
    self.email       = info.email
    self.description = info.description
    self.location    = extra_info.location.name
    self.save! if !self.newly_created && self.changed?
  end

  def setup_linkedin_account(auth)
    self.check_and_remove_existing_linkedin(auth.uid)
    self.build_linkedin.from_omniauth(auth)
    self.update_attributes(linkedin_uid: auth.uid)
  end
end
