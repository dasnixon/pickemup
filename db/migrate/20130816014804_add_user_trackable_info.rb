class AddUserTrackableInfo < ActiveRecord::Migration
  def change
    add_column :users, :last_sign_in_at, :timestamp
    add_column :users, :current_sign_in_at, :timestamp
    add_column :users, :last_sign_in_ip, :inet
    add_column :users, :current_sign_in_ip, :inet
    add_column :users, :sign_in_count, :integer
  end
end
