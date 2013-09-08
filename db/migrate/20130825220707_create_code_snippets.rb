class CreateCodeSnippets < ActiveRecord::Migration
  def change
    create_table :code_snippets, id: :uuid do |t|
      t.text       :description
      t.string     :url
      t.string     :gist_key
      t.boolean    :public
      t.integer    :comments_count
      t.string     :comments_url
      t.datetime   :gist_created_at
      t.uuid       :user_id
      t.timestamps
    end
  end
end
