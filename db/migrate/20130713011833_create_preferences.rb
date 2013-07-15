class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.integer   :expected_salary
      t.integer   :vacation_days
      t.boolean   :healthcare
      t.boolean   :equity
      t.boolean   :bonuses
      t.boolean   :retirement
      t.boolean   :fulltime
      t.boolean   :remote
      t.integer   :potential_availability
      t.boolean   :open_source
      t.int8range :company_size
      t.string    :skills, array: true, default: []
      t.string    :locations, array: true, default: []
      t.string    :industries, array: true, default: []
      t.string    :positions, array: true, default: []
      t.string    :settings, array: true, default: []
      t.string    :dress_codes, array: true, default: []
      t.string    :company_types, array: true, default: []
      t.string    :perks, array: true, default: []
      t.string    :practices, array: true, default: []
      t.belongs_to :user
      t.timestamps
    end
  end
end
