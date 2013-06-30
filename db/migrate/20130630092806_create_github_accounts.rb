class CreateGithubAccounts < ActiveRecord::Migration
  def change
    create_table :github_accounts do |t|
      t.string     :nickname
      t.string     :profile_image
      t.boolean    :hireable
      t.text       :bio
      t.integer    :public_repos_count
      t.integer    :number_followers
      t.integer    :number_following
      t.integer    :number_gists
      t.string     :token
      t.belongs_to :user
      t.timestamps
    end
  end
end
