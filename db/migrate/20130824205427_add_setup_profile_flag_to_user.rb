class AddSetupProfileFlagToUser < ActiveRecord::Migration
  def change
    add_column :users, :manually_setup_profile, :boolean, default: false
  end
end
