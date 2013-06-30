class Repo < ActiveRecord::Base
  belongs_to :github_account

  def self.from_omniauth(repos, github_id)
    repos.each do |repo|
      Repo.create(github_account_id: github_id) do |r|

      end
    end
  end
end
