class DropUnnecessaryColumnsFromPreferences < ActiveRecord::Migration
  def change
    remove_column :preferences, :dress_codes
    remove_column :preferences, :settings
  end
end
