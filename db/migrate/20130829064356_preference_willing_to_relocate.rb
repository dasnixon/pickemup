class PreferenceWillingToRelocate < ActiveRecord::Migration
  def change
    add_column :preferences, :willing_to_relocate, :boolean, default: false
  end
end
