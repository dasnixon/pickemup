class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations, id: :uuid do |t|
      t.string     :name
      t.string     :logo
      t.string     :url
      t.string     :organization_key
      t.string     :location
      t.integer    :number_followers
      t.integer    :number_following
      t.string     :blog
      t.integer    :public_repos_count
      t.string     :company_type
      t.uuid       :github_account_id
      t.timestamps
    end

    add_index :organizations, :organization_key
  end
end
