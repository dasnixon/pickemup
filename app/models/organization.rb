# == Schema Information
#
# Table name: organizations
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  avatar_url         :string(255)
#  url                :string(255)
#  organization_key   :string(255)
#  location           :string(255)
#  number_followers   :integer
#  number_following   :integer
#  blog               :string(255)
#  public_repos_count :integer
#  company_type       :string(255)
#  github_account_id  :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class Organization < ActiveRecord::Base
  belongs_to :github_account

  def self.from_omniauth(organizations, github_id)
    organizations.each do |org|
      Organization.create(github_account_id: github_id) do |o|
        org_info = o.github_account.get_org_information(org.login)
        o.avatar_url         = org.avatar_url
        o.organization_key   = org.id
        o.name               = org_info.try(:name) || org.login
        o.url                = org_info.html_url
        o.location           = org_info.try(:location)
        o.company_type       = org_info.type
        o.blog               = org_info.try(:blog)
        o.number_followers   = org_info.followers
        o.number_following   = org_info.following
        o.public_repos_count = org_info.public_repos
      end
    end
  end
end
