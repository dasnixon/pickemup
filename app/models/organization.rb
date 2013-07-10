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
      organization = Organization.find_or_initialize_by_organization_key_and_github_account_id(org.id.to_s, github_id)
      org_info = organization.github_account.get_org_information(org.login)
      organization.update_attributes(
        avatar_url:         org.avatar_url,
        name:               (org_info.try(:name) || org.login),
        url:                org_info.html_url,
        location:           org_info.try(:location),
        company_type:       org_info.type,
        blog:               org_info.try(:blog),
        number_followers:   org_info.followers,
        number_following:   org_info.following,
        public_repos_count: org_info.public_repos
      )
    end
  end
end
