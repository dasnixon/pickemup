class TechStackIdToUuid < ActiveRecord::Migration
  def change
    remove_index :job_listings, :tech_stack_id
    remove_column :job_listings, :tech_stack_id
    add_column :job_listings, :tech_stack_id, :uuid
    add_index :job_listings, :tech_stack_id
  end
end
