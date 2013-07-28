class CreateJobListings < ActiveRecord::Migration
  def change
    create_table :job_listings do |t|
      t.string :job_title
      t.string :job_description
      t.string :experience_level
      t.string :estimated_work_hours
      t.integer :salary_range_high
      t.integer :salary_range_low
      t.integer :vacation_days
      t.string :healthcare
      t.string :equity
      t.string :bonuses
      t.string :retirement
      t.json :perks
      t.json :practices, default: []
      t.boolean :fulltime, default: true
      t.boolean :remote
      t.integer :hiring_time
      t.integer :tech_stack_id
      t.json :acceptable_languages, default: []
      t.string :location
      t.string :position_type
      t.json :special_characteristics
      t.belongs_to :company, null: false
      t.boolean :active, default: false
      t.boolean :sponsorship_available, default: false
      t.timestamps
    end
  end
end
