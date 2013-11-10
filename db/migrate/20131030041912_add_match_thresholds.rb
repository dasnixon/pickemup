class AddMatchThresholds < ActiveRecord::Migration
  def change
    add_column :preferences, :match_threshold, :integer, :default => 0.5
    add_column :job_listings, :match_threshold, :integer, :default => 0.5
  end
end
