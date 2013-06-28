class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :uid, index: true, unique: true
      t.string  :email, index: true, unique: true
      t.string  :name
      t.string  :location
      t.string  :blog
      t.string  :current_company
      t.text    :description
      t.timestamps
    end
  end
end
