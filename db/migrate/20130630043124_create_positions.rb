class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.string     :industry
      t.string     :company_type
      t.string     :name
      t.string     :size
      t.string     :company_key
      t.boolean    :is_current
      t.string     :title
      t.text       :summary
      t.string     :start_year
      t.string     :start_month
      t.belongs_to :profile
      t.timestamps
    end
  end
end
