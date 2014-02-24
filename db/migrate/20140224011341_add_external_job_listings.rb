class AddExternalJobListings < ActiveRecord::Migration
  def change
    create_table :external_job_listings, id: :uuid do |t|
      t.string :job_title
      t.string :link
      t.string :creation_time
      t.string :company_url
      t.text :job_description
      t.string :skills, array: true, default: []
      t.integer :salary_range_high
      t.integer :salary_range_low
      t.timestamps
    end
  end
end
