class ChangeDataStructureOnJobListing < ActiveRecord::Migration
  def change
    remove_column :job_listings, :practices
    add_column :job_listings, :practices, :json, default: []
    remove_column :job_listings, :acceptable_languages
    add_column :job_listings, :acceptable_languages, :json, default: []
  end
end
