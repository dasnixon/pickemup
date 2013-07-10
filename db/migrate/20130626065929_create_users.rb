class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :uid, unique: true
      t.string  :email, unique: true
      t.string  :name
      t.string  :location
      t.string  :blog
      t.string  :current_company
      t.text    :description
      t.timestamps
    end

    add_index :users, :uid
    add_index :users, :email
  end
end
