class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.boolean   :healthcare
      t.boolean   :dentalcare
      t.boolean   :visioncare
      t.boolean   :life_insurance
      t.boolean   :paid_vacation
      t.boolean   :equity
      t.boolean   :bonuses
      t.boolean   :retirement
      t.boolean   :fulltime
      t.integer   :remote
      t.boolean   :open_source
      t.integer   :expected_salary
      t.integer   :potential_availability
      t.integer   :company_size
      t.integer   :work_hours
      t.hstore    :skills,                     default: {}
      t.string    :locations,     array: true, default: []
      t.string    :industries,    array: true, default: []
      t.string    :positions,     array: true, default: []
      t.string    :settings,      array: true, default: []
      t.string    :dress_codes,   array: true, default: []
      t.string    :company_types, array: true, default: []
      t.string    :perks,         array: true, default: []
      t.string    :practices,     array: true, default: []
      t.belongs_to :user
      t.timestamps
    end
  end
end
