class FinalJobListingDatastructures < ActiveRecord::Migration
  def change
    remove_column :job_listings, :healthcare
    add_column :job_listings, :healthcare, :boolean, :default => false
    add_column :job_listings, :dental, :boolean, :default => false
    add_column :job_listings, :vision, :boolean, :default => false
    add_column :job_listings, :life_insurance, :boolean, :default => false
    remove_column :job_listings, :retirement
    add_column :job_listings, :retirement, :boolean, :default => false
    remove_column :job_listings, :estimated_work_hours
    add_column :job_listings, :estimated_work_hours, :integer
    remove_column :job_listings, :practices
    add_column :job_listings, :practices, :string, :default => [], array: true
    remove_column :job_listings, :perks
    remove_column :job_listings, :acceptable_languages
    add_column :job_listings, :acceptable_languages, :string, :default => [], array: true
    remove_column :job_listings, :special_characteristics
    add_column :job_listings, :special_characteristics, :string, :default => [], array: true
    remove_column :job_listings, :experience_level
    add_column :job_listings, :experience_level, :string, :default => [], array: true
  end
end
