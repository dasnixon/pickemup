# == Schema Information
#
# Table name: code_snippets
#
#  id              :uuid             not null, primary key
#  description     :text
#  url             :string(255)
#  gist_key        :string(255)
#  public          :boolean
#  comments_count  :integer
#  comments_url    :string(255)
#  gist_created_at :datetime
#  user_id         :uuid
#  created_at      :datetime
#  updated_at      :datetime
#

class CodeSnippet < ActiveRecord::Base
end
