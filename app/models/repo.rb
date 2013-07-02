# == Schema Information
#
# Table name: repos
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  description       :text
#  private           :boolean
#  url               :string(255)
#  language          :string(255)
#  number_forks      :integer
#  number_watchers   :integer
#  size              :integer
#  open_issues       :integer
#  started           :datetime
#  last_updated      :datetime
#  repo_key          :string(255)
#  github_account_id :integer
#  created_at        :datetime
#  updated_at        :datetime
#

class Repo < ActiveRecord::Base
  belongs_to :github_account

  def self.from_omniauth(repos, github_id)
    repos.each do |repo|
      Repo.create(github_account_id: github_id) do |r|
        r.name            = repo.name
        r.description     = repo.description
        r.private         = repo.private
        r.url             = repo.html_url
        r.language        = repo.language
        r.number_forks    = repo.forks
        r.number_watchers = repo.watchers
        r.size            = repo.size
        r.open_issues     = repo.open_issues_count
        r.started         = repo.created_at
        r.last_updated    = repo.updated_at
        r.repo_key        = repo.id
      end
    end
  end
end
