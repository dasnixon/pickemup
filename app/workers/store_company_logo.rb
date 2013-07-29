class StoreCompanyLogo
  include Sidekiq::Worker

  def perform(company_id, image_url)
    company = Company.find(company_id)
    return if company.blank?
    company.set_company_logo(image_url)
  end
end
