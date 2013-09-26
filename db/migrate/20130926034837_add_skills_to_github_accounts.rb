class AddSkillsToGithubAccounts < ActiveRecord::Migration
  def change
    add_column :github_accounts, :skills, :string, array: true, default: []
  end
end
