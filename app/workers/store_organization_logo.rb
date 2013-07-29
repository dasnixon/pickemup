class StoreOrganizationLogo
  include Sidekiq::Worker

  def perform(org_id, image_url)
    org = Organization.find(org_id)
    return if org.blank?
    org.set_organization_logo(image_url)
  end
end
