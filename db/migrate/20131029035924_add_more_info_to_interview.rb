class AddMoreInfoToInterview < ActiveRecord::Migration
  def change
    add_column :interviews, :duration, :integer
    add_column :interviews, :description, :text
  end
end
