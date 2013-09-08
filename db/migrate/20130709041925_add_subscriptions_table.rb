class AddSubscriptionsTable < ActiveRecord::Migration
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.integer :plan
      t.uuid    :company_id,          null: false
      t.string  :stripe_customer_token
      t.string  :stripe_card_token
      t.boolean :active,                          default: false
      t.string  :email
      t.timestamps
    end
  end
end
