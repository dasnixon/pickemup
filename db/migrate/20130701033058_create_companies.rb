class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies, id: :uuid do |t|
      t.string :name
      t.string :email, :index => true, :unique => true
      t.string :password_salt
      t.string :password_hash
      t.text   :description
      t.string :website
      t.string :industry
      t.string :num_employees
      t.boolean :public, :default => false
      t.date :founded
      t.timestamps
    end
  end
end
