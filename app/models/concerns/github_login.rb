module GithubLogin
  extend ActiveSupport::Concern

  def set_user_github_information(auth)
    self.newly_created = true
    self.main_provider = 'github'
    self.set_attributes_from_github(auth)
    self.build_github_account.from_omniauth(auth)
  end

  def check_and_remove_existing_github(uid)
    user = User.where(github_uid: uid)
    user.first.destroy if user.present? && self != user.first
  end

  #update information for a persisted user (not a new user) including all their
  #github, linkedin, and stackexchange information, and any updated inforation
  #on the user
  def update_github_information(auth)
    self.github_account.from_omniauth(auth)
    self.set_attributes_from_github(auth)
    UserInformationWorker.perform_async(self.id) #this will call the update_resume method
  end

  def setup_github_account(auth)
    self.check_and_remove_existing_github(auth.uid)
    self.build_github_account.from_omniauth(auth)
    self.update_attributes(github_uid: auth.uid)
  end

  #set attributes from the github auth information on the user
  def set_attributes_from_github(auth)
    info             = auth.info
    extra_info       = auth.extra.raw_info
    self.name        = info.name
    self.email       = info.email
    self.description = info.description
    self.location    = extra_info.location
    self.save! if !self.newly_created && self.changed?
  end
end
