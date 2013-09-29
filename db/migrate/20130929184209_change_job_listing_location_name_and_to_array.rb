class ChangeJobListingLocationNameAndToArray < ActiveRecord::Migration
  def change
    remove_column :job_listings, :location
    add_column :job_listings, :locations, :string, array: true, default: []
  end
end
