class CreateStackexchanges < ActiveRecord::Migration
  def change
    create_table :stackexchanges do |t|
      t.string     :token
      t.string     :uid
      t.string     :profile_url
      t.integer    :reputation
      t.integer    :age
      t.string     :profile_image
      t.hstore     :badges
      t.string     :display_name
      t.string     :nickname
      t.string     :stackexchange_key
      t.belongs_to :user
      t.timestamps
    end
  end
end
