class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles, id: :uuid do |t|
      t.integer    :number_connections
      t.integer    :number_recommenders
      t.text       :summary
      t.string     :skills, array: true, default: []
      t.uuid       :linkedin_id
      t.timestamps
    end

    add_index :profiles, :linkedin_id, unique: true
  end
end
