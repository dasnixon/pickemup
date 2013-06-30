class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string     :name
      t.text       :description
      t.boolean    :private
      t.string     :url
      t.string     :language
      t.integer    :number_forks
      t.integer    :number_watchers
      t.integer    :size
      t.integer    :open_issues
      t.datetime   :started
      t.datetime   :last_updated
      t.string     :repo_key
      t.belongs_to :github_account
      t.timestamps
    end
  end
end
