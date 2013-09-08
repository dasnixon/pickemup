class CreateEducations < ActiveRecord::Migration
  def change
    create_table :educations, id: :uuid do |t|
      t.text       :activities
      t.string     :degree
      t.string     :field_of_study
      t.text       :notes
      t.string     :school_name
      t.string     :start_year
      t.string     :end_year
      t.string     :education_key
      t.uuid       :profile_id
      t.timestamps
    end

    add_index :educations, :education_key
  end
end
