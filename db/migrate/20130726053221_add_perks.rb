class AddPerks < ActiveRecord::Migration
  def change
    add_column :job_listings, :perks, :string, :default => [], array: true
  end
end
