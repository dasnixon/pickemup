class AddJobListingIdToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :job_listing_id, :uuid, null: false
  end
end
