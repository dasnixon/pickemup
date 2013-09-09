class AddActiveToCompanyAndUser < ActiveRecord::Migration
  def change
    add_column :users, :active, :boolean, default: true
    add_column :companies, :active, :boolean, default: true
  end
end
