# == Schema Information
#
# Table name: organizations
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  logo               :string(255)
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
      organization = Organization.where(organization_key: org.id.to_s, github_account_id: github_id).first_or_initialize
      org_info = organization.github_account.get_org_information(org.login)
      organization.update(
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

  #remove any organizations that we have in our system that the user no longer
  #belongs to on github
  def self.remove_orgs(organizations, org_keys)
    (org_keys - organizations.collect { |org| org.id.to_s }).each do |diff_id|
      Organization.find_by(organization_key: diff_id).try(:destroy)
    end
  end

  #uses carrierwave/fog to :ave the user's organization logo from github to S3
  def set_organization_logo(image_url)
    begin
      self.remote_logo_url = image_url
      self.save!
    rescue Exception => e
      logger.error "Creating logo S3 error for github organization #{e}"
    end
  end
end
