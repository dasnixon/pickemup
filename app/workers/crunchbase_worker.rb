class CrunchbaseWorker
  include Sidekiq::Worker

  def perform(company_id)
    company = Company.find(company_id)
    return if company.blank?
    company.get_crunchbase_info if company
  end
end
