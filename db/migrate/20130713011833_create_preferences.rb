class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.boolean    :healthcare
      t.boolean    :dentalcare
      t.boolean    :visioncare
      t.boolean    :life_insurance
      t.boolean    :paid_vacation
      t.boolean    :equity
      t.boolean    :bonuses
      t.boolean    :retirement
      t.boolean    :fulltime
      t.integer    :remote
      t.boolean    :open_source
      t.integer    :expected_salary
      t.integer    :potential_availability
      t.integer    :company_size
      t.integer    :work_hours
      t.json       :skills
      t.json       :locations
      t.json       :industries
      t.json       :positions
      t.json       :settings
      t.json       :dress_codes
      t.json       :company_types
      t.json       :perks
      t.json       :practices
      t.json       :levels
      t.belongs_to :user
      t.timestamps
    end
  end
end
