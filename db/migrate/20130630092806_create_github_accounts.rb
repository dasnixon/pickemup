class CreateGithubAccounts < ActiveRecord::Migration
  def change
    create_table :github_accounts, id: :uuid do |t|
      t.string     :nickname
      t.boolean    :hireable
      t.text       :bio
      t.integer    :public_repos_count
      t.integer    :number_followers
      t.integer    :number_following
      t.integer    :number_gists
      t.string     :blog
      t.string     :token
      t.string     :github_account_key
      t.string     :uid
      t.uuid       :user_id
      t.timestamps
    end

    add_index :github_accounts, :github_account_key
    add_index :github_accounts, :uid
    add_index :github_accounts, :user_id, unique: true
  end
end
