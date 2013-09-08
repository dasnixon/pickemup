# This migration comes from mailboxer_engine (originally 20130305144212)
class AddGlobalNotificationSupport < ActiveRecord::Migration

  def change
    change_table :notifications, id: :uuid do |t|
      t.boolean :global, default: false
      t.datetime :expires
    end
  end
end
