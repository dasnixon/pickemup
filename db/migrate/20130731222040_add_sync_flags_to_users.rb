class AddSyncFlagsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stackexchange_synced, :boolean, default: false
  end
end
