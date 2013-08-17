class SearchSuggestions
  def initialize(app)
    @app = app
  end

  def call(env)
    if env["PATH_INFO"] == "/company_search"
      request = Rack::Request.new(env)
      terms = Company.search_by(:name, request.params["term"])
      [200, {"Content-Type" => "appication/json"}, [terms.to_json]]
    else
      @app.call(env)
    end
  end
end
