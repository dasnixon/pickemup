class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :educations, :profile_id
    add_index :job_listings, :company_id
    add_index :job_listings, :tech_stack_id
    add_index :tech_stacks, :company_id
    add_index :organizations, :github_account_id
    add_index :positions, :profile_id
  end
end
