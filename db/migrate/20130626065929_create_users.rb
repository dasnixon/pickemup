class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :provider
      t.string  :uid
      t.string  :email
      t.string  :nickname
      t.string  :name
      t.string  :github_profile_image
      t.string  :location
      t.string  :blog
      t.string  :current_company
      t.boolean :hireable
      t.text    :description
      t.text    :github_bio
      t.integer :public_repos_count
      t.integer :github_number_followers
      t.integer :github_number_following
      t.integer :github_number_public_gists
      t.string  :github_token
      t.string  :linkedin_token
      t.string  :headline
      t.string  :industry
      t.string  :linkedin_uid
      t.string  :linkedin_profile_url
      t.timestamps
    end
  end
end
