# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  uid             :string(255)
#  email           :string(255)
#  name            :string(255)
#  location        :string(255)
#  blog            :string(255)
#  current_company :string(255)
#  description     :text
#  created_at      :datetime
#  updated_at      :datetime
#

class User < ActiveRecord::Base
  has_one :github_account, dependent: :destroy
  has_one :linkedin, dependent: :destroy

  def self.from_omniauth(auth)
    User.where(auth.slice(:uid)).first_or_create do |user|
      info                 = auth.info
      extra_info           = auth.extra.raw_info
      user.name            = info.name
      user.email           = info.email
      user.location        = extra_info.location
      user.blog            = extra_info.blog
      user.current_company = extra_info.company
      user.build_github_account.from_omniauth(auth)
    end
  end

  def has_linkedin_synced?
    self.linkedin.try(:uid).present?
  end
end
