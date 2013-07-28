class ChangeJobListingColumns < ActiveRecord::Migration
  def change
    remove_column :job_listings, :perks
    add_column :job_listings, :perks, :json, default: []
    remove_column :job_listings, :special_characteristics
    add_column :job_listings, :special_characteristics, :json, default: []
    remove_column :job_listings, :experience_level
    add_column :job_listings, :experience_level, :json, default: []
  end
end
