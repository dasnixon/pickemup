module PickemupAPI
  require 'JSON'
  extend ActiveSupport::Concern
  include HTTParty

  def api_update
    class_name = self.class.name.underscore
    timeout = 5
    begin
      Timeout::timeout(timeout) do
        return HTTParty.post(ENV["PICKEMUP_API_BASE_URL"] + "#{class_name.pluralize}/update?", body: {class_name => self.api_attributes}.to_json, basic_auth: PickemupAPI::auth_info, :headers => { 'Content-Type' => 'application/json' })
      end
    rescue
    end
  end

  def api_create
    class_name = self.class.name.underscore
    timeout = 5
    begin
      Timeout::timeout(timeout) do
        return HTTParty.post(ENV["PICKEMUP_API_BASE_URL"] + "#{class_name.pluralize}/create?", body: {class_name => self.api_attributes}.to_json, basic_auth: PickemupAPI::auth_info, :headers => { 'Content-Type' => 'application/json' })
      end
    rescue
    end
  end

  def self.api_retrieve(query_params, path)
    attempts = 0
    timeout = 5
    begin
      Timeout::timeout(timeout) do
        return JSON.parse(HTTParty.get(ENV["PICKEMUP_API_BASE_URL"] + "#{path}/retrieve?", body: {path.singularize => query_params}.to_json, basic_auth: auth_info, :headers => { 'Content-Type' => 'application/json' }).body)
      end
    rescue
      attempts += 1
      timeout = 3
      retry unless attempts >= 2
    end
  end

  def api_destroy
    class_name = self.class.name.underscore
    attempts = 0
    timeout = 5
    begin
      Timeout::timeout(timeout) do
        return HTTParty.post(ENV["PICKEMUP_API_BASE_URL"] + "#{class_name.pluralize}/destroy?", body: {class_name => self.api_attributes}.to_json, basic_auth: PickemupAPI::auth_info, :headers => { 'Content-Type' => 'application/json' })
      end
    rescue
    end
  end

  private

  def self.auth_info
    {"key" => ENV['PICKEMUP_API_KEY'], "secret" => ENV['PICKEMUP_API_SECRET']}
  end
end
