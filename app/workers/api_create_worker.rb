class APICreateWorker
  include Sidekiq::Worker

  def perform(model_id, class_name)
    model = class_name.constantize.find(model_id)
    api_response = model.api_create
    APILogger.new('CREATE').log(model_id, class_name, api_response.status) unless api_response.status == 200
  end
end
