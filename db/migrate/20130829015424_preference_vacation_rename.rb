class PreferenceVacationRename < ActiveRecord::Migration
  def change
    rename_column :preferences, :paid_vacation, :vacation_days
    rename_column :preferences, :dentalcare, :dental
    rename_column :preferences, :visioncare, :vision
  end
end
