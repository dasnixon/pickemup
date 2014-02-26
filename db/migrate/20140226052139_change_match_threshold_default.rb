class ChangeMatchThresholdDefault < ActiveRecord::Migration
  def change
    change_column_default(:job_listings, :match_threshold, 0)
    change_column_default(:preferences, :match_threshold, 0)
  end
end
