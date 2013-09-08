# This migration comes from mailboxer_engine (originally 20110719110700)
class AddNotifiedObject < ActiveRecord::Migration
  def self.up
    change_table :notifications, id: :uuid do |t|
      t.uuid   :notified_object_id
      t.uuid   :notified_object_type
      t.remove :object_id
      t.remove :object_type
    end
  end

  def self.down
    change_table :notifications do |t|
      t.remove :notified_object_id
      t.remove :notified_object_type
      t.uuid :object_id
      t.string :object_type
    end
  end
end
