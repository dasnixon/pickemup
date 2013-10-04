class AddSynopsisToJobListings < ActiveRecord::Migration
  def change
    add_column :job_listings, :synopsis, :text, limit: 300
  end
end
