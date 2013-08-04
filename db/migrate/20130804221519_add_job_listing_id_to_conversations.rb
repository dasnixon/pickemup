class AddJobListingIdToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :job_listing_id, :integer, null: false
  end
end
