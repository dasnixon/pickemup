class CreateLinkedins < ActiveRecord::Migration
  def change
    create_table :linkedins do |t|
      t.string     :token
      t.string     :headline
      t.string     :industry
      t.string     :uid
      t.string     :profile_url
      t.belongs_to :user
      t.timestamps
    end
  end
end
