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
  attr_accessible :name, :avatar_url, :url, :location,
    :number_followers, :number_following, :blog,
    :public_repos_count, :company_type

  belongs_to :github_account

  mount_uploader :logo, AvatarUploader #carrierwave

  def self.from_omniauth(organizations, github_id, org_keys=nil)
    Organization.remove_orgs(organizations, org_keys) if org_keys.present?
    organizations.each do |org|
      organization = Organization.find_or_initialize_by_organization_key_and_github_account_id(org.id.to_s, github_id)
      org_info = organization.github_account.get_org_information(org.login)
      organization.update_attributes(
        name:               (org_info.try(:name) || org.login),
        url:                org_info.html_url,
        location:           org_info.try(:location),
        company_type:       org_info.type,
        blog:               org_info.try(:blog),
        number_followers:   org_info.followers,
        number_following:   org_info.following,
        public_repos_count: org_info.public_repos
      )
      StoreOrganizationLogo.perform_async(organization.id, org.avatar_url)
    end
  end

  def self.remove_orgs(organizations, org_keys)
    (org_keys - organizations.collect { |org| org.id.to_s }).each do |diff_id|
      Organization.where(organization_key: diff_id).first.try(:destroy)
    end
  end

  def set_organization_logo(image_url)
    self.remote_logo_url = image_url
    self.save!
  end
end
