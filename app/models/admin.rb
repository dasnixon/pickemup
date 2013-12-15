class Admin < ActiveRecord::Base
  #This class can only be created from the console and the encrypt_password method must be called manually

  def self.authenticate(email, password, request)
    admin = find_by(email: email)
    if admin && admin.password_hash == BCrypt::Engine.hash_secret(password, admin.password_salt)
      admin
    else
      nil
    end
  end

  def encrypt_password(password)
    self.password_salt = BCrypt::Engine.generate_salt
    self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
  end
end
