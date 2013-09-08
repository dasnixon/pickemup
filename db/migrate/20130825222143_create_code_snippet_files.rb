class CreateCodeSnippetFiles < ActiveRecord::Migration
  def change
    create_table :code_snippet_files, id: :uuid do |t|
      t.string     :name
      t.text       :content
      t.integer    :size
      t.string     :url
      t.uuid       :code_snippet_id
      t.timestamps
    end
  end
end
