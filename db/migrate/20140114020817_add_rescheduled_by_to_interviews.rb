class AddRescheduledByToInterviews < ActiveRecord::Migration
  def change
    add_column :interviews, :rescheduled_by, :string
  end
end
