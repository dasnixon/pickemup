class AddDefaultToStatus < ActiveRecord::Migration
  def change
    change_column :interviews, :status, :string, default: :pending
  end
end
