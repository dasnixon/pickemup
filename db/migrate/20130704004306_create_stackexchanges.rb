class CreateStackexchanges < ActiveRecord::Migration
  def change
    create_table :stackexchanges, id: :uuid do |t|
      t.string     :token
      t.string     :uid
      t.string     :profile_url
      t.integer    :reputation
      t.integer    :age
      t.hstore     :badges
      t.string     :display_name
      t.string     :nickname
      t.string     :stackexchange_key
      t.uuid       :user_id
      t.timestamps
    end

    add_index :stackexchanges, :stackexchange_key
  end
end
