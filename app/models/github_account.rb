class GithubAccount < ActiveRecord::Base
  belongs_to :user
  has_many :repos, class_name: 'Repo', foreign_key: 'github_account_id', dependent: :destroy

  after_create :grab_github_information

  def from_omniauth(auth)
    info                    = auth.info
    extra_info              = auth.extra.raw_info
    self.nickname           = info.nickname
    self.profile_image      = info.image
    self.hireable           = extra_info.hireable
    self.bio                = extra_info.bio
    self.public_repos_count = extra_info.public_repos
    self.number_followers   = extra_info.followers
    self.number_following   = extra_info.following
    self.number_gists       = extra_info.public_gists
    self.token              = auth.credentials.token
    self.save!
  end

  def grab_github_information
    GithubWorker.perform_async(self.id)
  end

  def setup_information
    repos = get_repos
    Repo.from_omniauth(repos, self.id)
  end

  private

  def github_api_setup
    @github_api ||= Github.new(oauth_token: self.token)
  end

  def get_repos
    repos = github_api_setup.repos.list
  end
end
