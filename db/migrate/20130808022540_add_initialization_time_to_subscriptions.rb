class AddInitializationTimeToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :started_at, :timestamp
  end
end
