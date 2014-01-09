class AddEndYearAndMonthToPositions < ActiveRecord::Migration
  def change
    add_column :positions, :end_year, :string
    add_column :positions, :end_month, :string
  end
end
