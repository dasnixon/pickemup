class ChangeFulltimeDefaultToTrue < ActiveRecord::Migration
  def change
    change_column :preferences, :fulltime, :boolean, default: true
  end
end
