class AddAdminClass < ActiveRecord::Migration
  def change
    create_table :admins, id: :uuid do |t|
      t.string  :email
      t.string  :name
      t.string  :password_salt
      t.string  :password_hash
      t.timestamps
    end
  end
end
