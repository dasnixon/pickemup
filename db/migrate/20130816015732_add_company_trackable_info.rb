class AddCompanyTrackableInfo < ActiveRecord::Migration
  def change
    add_column :companies, :last_sign_in_at, :timestamp
    add_column :companies, :current_sign_in_at, :timestamp
    add_column :companies, :last_sign_in_ip, :inet
    add_column :companies, :current_sign_in_ip, :inet
    add_column :companies, :sign_in_count, :integer
  end
end
