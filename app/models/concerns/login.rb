module Login
  extend ActiveSupport::Concern

  %w(github_account linkedin).each do |method|
    associated = method == 'github_account' ? 'github' : method

    define_method "set_user_#{method}_information" do |auth|
      self.newly_created = true
      self.main_provider = auth.provider
      return nil unless self.send("set_attributes_from_#{method}", auth)
      self.send("build_#{method}").from_omniauth(auth)
    end

    define_method "check_and_remove_existing_#{method}" do |uid|
      user = User.find_by("#{associated}_uid" => uid)
      user.destroy if user && self != user
    end

    define_method "setup_#{associated}_account" do |auth|
      self.send("check_and_remove_existing_#{method}", auth.uid)
      self.send("build_#{method}").from_omniauth(auth)
      self.update("#{associated}_uid" => auth.uid)
    end

    define_method "update_#{method}_information" do |auth|
      association = self.send(method)
      association.present? ? association.from_omniauth(auth) : self.send("build_#{method}").from_omniauth(auth)
      self.send("set_attributes_from_#{method}", auth)
      UserInformationWorker.perform_async(self.id) #this will call the update_resume method
    end

    define_method "post_#{method}_setup" do |auth|
      opposite = auth.provider == 'github' ? 'linkedin' : 'github'
      StoreUserProfileImage.perform_async(self.id, auth.info.image) unless self.main_provider == opposite
      if !self.newly_created
        if self.main_provider == opposite
          self.send(method).update(token: auth.credentials.token)
          UserInformationWorker.perform_async(self.id)
        else
          self.send("update_#{method}_information", auth)
        end
      end
    end

    define_method "set_attributes_from_#{method}" do |auth|
      self.update_tracked_fields!(self.request) if self.track and self.request
      if !self.manually_setup_profile
        info             = auth.info
        extra_info       = auth.extra.raw_info
        self.name        = info.name
        self.email       = info.email
        self.description = info.description
        self.location    = auth.provider == 'github' ? extra_info.location : extra_info.location.name
      end
      self.save
    end
  end
end
