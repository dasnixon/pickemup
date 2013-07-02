# == Schema Information
#
# Table name: github_accounts
#
#  id                 :integer          not null, primary key
#  nickname           :string(255)
#  profile_image      :string(255)
#  hireable           :boolean
#  bio                :text
#  public_repos_count :integer
#  number_followers   :integer
#  number_following   :integer
#  number_gists       :integer
#  token              :string(255)
#  user_id            :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class GithubAccount < ActiveRecord::Base
  include Extensions

  belongs_to :user
  has_many :repos, class_name: 'Repo', foreign_key: 'github_account_id', dependent: :destroy
  has_many :organizations, dependent: :destroy

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
    Repo.from_omniauth(get_repos, self.id)
    Organization.from_omniauth(get_organizations, self.id)
  end

  def most_common_language
    self.repos.collect { |repo| repo.language }.mode
  end

  def get_org_information(name)
    github_api_setup.orgs.get(name)
  end

  private

  def github_api_setup
    @github_api ||= Github.new(oauth_token: self.token)
  end

  def get_repos
    github_api_setup.repos.list
  end

  def get_organizations
    github_api_setup.organizations.list
  end
end
