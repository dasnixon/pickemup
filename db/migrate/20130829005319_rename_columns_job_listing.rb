class RenameColumnsJobListing < ActiveRecord::Migration
  def change
    rename_column :job_listings, :position_type, :position_titles
    rename_column :job_listings, :experience_level, :experience_levels
    rename_column :preferences, :positions, :position_titles
    rename_column :preferences, :levels, :experience_levels
  end
end
