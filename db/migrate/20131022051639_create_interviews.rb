class CreateInterviews < ActiveRecord::Migration
  def change
    create_table :interviews, id: :uuid do |t|
      t.string     :status
      t.boolean    :hireable
      t.datetime   :request_date
      t.uuid       :job_listing_id
      t.uuid       :company_id
      t.uuid       :user_id
      t.timestamps
    end

    add_index :interviews, [:user_id, :company_id, :job_listing_id], unique: true
  end
end
