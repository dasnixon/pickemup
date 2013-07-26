class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.boolean    :healthcare,             default: false
      t.boolean    :dentalcare,             default: false
      t.boolean    :visioncare,             default: false
      t.boolean    :life_insurance,         default: false
      t.boolean    :paid_vacation,          default: false
      t.boolean    :equity,                 default: false
      t.boolean    :bonuses,                default: false
      t.boolean    :retirement,             default: false
      t.boolean    :fulltime,               default: false
      t.boolean    :us_citizen,             default: false
      t.boolean    :open_source,            default: false
      t.integer    :expected_salary,        default: 0
      t.integer    :potential_availability, default: 0
      t.integer    :work_hours,             default: 0
      t.string     :remote,                 array: true, default: []
      t.string     :company_size,           array: true, default: []
      t.string     :skills,                 array: true, default: []
      t.string     :locations,              array: true, default: []
      t.string     :industries,             array: true, default: []
      t.string     :positions,              array: true, default: []
      t.string     :settings,               array: true, default: []
      t.string     :dress_codes,            array: true, default: []
      t.string     :company_types,          array: true, default: []
      t.string     :perks,                  array: true, default: []
      t.string     :practices,              array: true, default: []
      t.string     :levels,                 array: true, default: []
      t.belongs_to :user
      t.timestamps
    end
  end
end
