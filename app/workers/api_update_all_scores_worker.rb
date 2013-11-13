class APIUpdateAllScoresWorker
  include HTTParty
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly }

  def perform
    HTTParty.get(ENV["PICKEMUP_API_BASE_URL"] + "scores/update_all_scores", :headers => { 'Content-Type' => 'application/json' })
  end
end
