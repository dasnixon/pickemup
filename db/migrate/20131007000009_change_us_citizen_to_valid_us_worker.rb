class ChangeUsCitizenToValidUsWorker < ActiveRecord::Migration
  def change
    rename_column :preferences, :us_citizen, :valid_us_worker
  end
end
