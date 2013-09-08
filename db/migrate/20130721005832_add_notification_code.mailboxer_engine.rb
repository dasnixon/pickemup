# This migration comes from mailboxer_engine (originally 20110912163911)
class AddNotificationCode < ActiveRecord::Migration
  def self.up
    change_table :notifications, id: :uuid do |t|
      t.string :notification_code, :default => nil
    end
  end

  def self.down
    change_table :notifications, id: :uuid do |t|
      t.remove :notification_code
    end
  end
end