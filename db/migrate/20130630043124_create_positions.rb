class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions, id: :uuid do |t|
      t.string     :industry
      t.string     :company_type
      t.string     :name
      t.string     :size
      t.string     :position_key
      t.boolean    :is_current
      t.string     :title
      t.text       :summary
      t.string     :start_year
      t.string     :start_month
      t.uuid       :profile_id
      t.timestamps
    end

    add_index :positions, :position_key
  end
end
