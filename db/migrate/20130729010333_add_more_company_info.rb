class AddMoreCompanyInfo < ActiveRecord::Migration
  def change
    add_column :companies, :acquired_by, :string
    add_column :companies, :tags, :string, default: [], array: true
    add_column :companies, :total_money_raised, :string
    add_column :companies, :competitors, :string, default: [], array: true
    add_column :companies, :logo, :string
  end
end
