class CreateJobListings < ActiveRecord::Migration
  def change
    create_table :job_listings, id: :uuid do |t|
      t.string   :job_title
      t.text     :job_description
      t.integer  :salary_range_high
      t.integer  :salary_range_low
      t.integer  :vacation_days
      t.string   :equity
      t.string   :bonuses
      t.boolean  :fulltime,                default: true
      t.boolean  :remote
      t.integer  :hiring_time
      t.integer  :tech_stack_id
      t.string   :location
      t.boolean  :active,                  default: false
      t.boolean  :sponsorship_available,   default: false
      t.boolean  :healthcare,              default: false
      t.boolean  :dental,                  default: false
      t.boolean  :vision,                  default: false
      t.boolean  :life_insurance,          default: false
      t.boolean  :retirement,              default: false
      t.integer  :estimated_work_hours
      t.string   :practices,               default: [],                 array: true
      t.string   :acceptable_languages,    default: [],                 array: true
      t.string   :special_characteristics, default: [],                 array: true
      t.string   :experience_level,        default: [],                 array: true
      t.string   :perks,                   default: [],                 array: true
      t.string   :position_type,           default: [],                 array: true
      t.timestamps
      t.uuid     :company_id
    end
  end
end
