class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, id: :uuid do |t|
      t.string  :github_uid,   unique: true
      t.string  :linkedin_uid, unique: true
      t.string  :email
      t.string  :name
      t.string  :location
      t.string  :profile_image
      t.string  :main_provider
      t.text    :description
      t.timestamps
    end

    add_index :users, :github_uid
    add_index :users, :linkedin_uid
    add_index :users, :email, unique: true
  end
end
