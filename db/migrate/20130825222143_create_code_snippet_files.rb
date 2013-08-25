class CreateCodeSnippetFiles < ActiveRecord::Migration
  def change
    create_table :code_snippet_files do |t|
      t.string     :name
      t.text       :content
      t.integer    :size
      t.string     :url
      t.belongs_to :code_snippet
      t.timestamps
    end
  end
end
