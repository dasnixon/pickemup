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
      t.json       :remote,                 default: {}
      t.json       :company_size,           default: {}
      t.json       :skills,                 default: {}
      t.json       :locations,              default: {}
      t.json       :industries,             default: {}
      t.json       :positions,              default: {}
      t.json       :settings,               default: {}
      t.json       :dress_codes,            default: {}
      t.json       :company_types,          default: {}
      t.json       :perks,                  default: {}
      t.json       :practices,              default: {}
      t.json       :levels,                 default: {}
      t.belongs_to :user
      t.timestamps
    end
  end
end
