class CreateTechStacks < ActiveRecord::Migration
  def change
    create_table :tech_stacks, id: :uuid do |t|
      t.uuid   :company_id
      t.string :name
      t.string :back_end_languages, array: true, default: []
      t.string :front_end_languages, array: true, default: []
      t.string :frameworks, array: true, default: []
      t.string :dev_ops_tools, array: true, default: []
      t.timestamps
    end
  end
end
