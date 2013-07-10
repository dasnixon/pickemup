class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.integer    :number_connections
      t.integer    :number_recommenders
      t.text       :summary
      t.string     :skills, array: true, default: []
      t.belongs_to :linkedin
      t.timestamps
    end
  end
end
