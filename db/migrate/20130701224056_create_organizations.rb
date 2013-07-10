class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string     :name
      t.string     :avatar_url
      t.string     :url
      t.string     :organization_key
      t.string     :location
      t.integer    :number_followers
      t.integer    :number_following
      t.string     :blog
      t.integer    :public_repos_count
      t.string     :company_type
      t.belongs_to :github_account
      t.timestamps
    end

    add_index :organizations, :organization_key
  end
end
