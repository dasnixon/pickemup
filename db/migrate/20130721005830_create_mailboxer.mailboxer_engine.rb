# This migration comes from mailboxer_engine (originally 20110511145103)
class CreateMailboxer < ActiveRecord::Migration
  def self.up
  #Tables
  	#Conversations
    create_table :conversations, id: :uuid do |t|
      t.column :subject, :string, :default => ""
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end
  	#Receipts
    create_table :receipts, id: :uuid do |t|
      t.uuid   :receiver_id
      t.string :receiver_type
      t.uuid   :notification_id, :null => false
      t.column :read, :boolean, :default => false
      t.column :trashed, :boolean, :default => false
      t.column :deleted, :boolean, :default => false
      t.column :mailbox_type, :string, :limit => 25
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end
  	#Notifications and Messages
    create_table :notifications, id: :uuid do |t|
      t.column :type, :string
      t.column :body, :text
      t.column :subject, :string, :default => ""
      t.uuid   :sender_id
      t.string :sender_type
      t.uuid   :object_id
      t.string :object_type
      t.uuid   :conversation_id
      t.column :draft, :boolean, :default => false
      t.column :updated_at, :datetime, :null => false
      t.column :created_at, :datetime, :null => false
    end


  #Indexes
  	#Conversations
  	#Receipts
  	add_index "receipts","notification_id"

  	#Messages
  	add_index "notifications","conversation_id"
  end

  def self.down
  #Tables
  	remove_foreign_key "receipts", :name => "receipts_on_notification_id"
  	remove_foreign_key "notifications", :name => "notifications_on_conversation_id"

  #Indexes
    drop_table :receipts
    drop_table :conversations
    drop_table :notifications
  end
end
