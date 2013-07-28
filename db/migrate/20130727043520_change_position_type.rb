class ChangePositionType < ActiveRecord::Migration
  def change
    remove_column :job_listings, :position_type, :string
    add_column :job_listings, :position_type, :string, default: [], array: true
  end
end
