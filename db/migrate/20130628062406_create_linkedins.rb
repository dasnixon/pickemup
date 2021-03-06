class CreateLinkedins < ActiveRecord::Migration
  def change
    create_table :linkedins, id: :uuid do |t|
      t.string     :token
      t.string     :headline
      t.string     :industry
      t.string     :uid
      t.string     :profile_url
      t.uuid       :user_id
      t.timestamps
    end

    add_index :linkedins, :uid
    add_index :linkedins, :user_id, unique: true
  end
end
