class GithubWorker
  include Sidekiq::Worker

  def perform(github_id)
    github = GithubAccount.find(github_id)
    return if github.blank?
    github.setup_information
  end
end
