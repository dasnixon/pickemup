class AddLocationToInterview < ActiveRecord::Migration
  def change
    add_column :interviews, :location, :string
  end
end
