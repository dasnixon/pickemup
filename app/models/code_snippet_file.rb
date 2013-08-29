# == Schema Information
#
# Table name: code_snippet_files
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  content         :text
#  size            :integer
#  url             :string(255)
#  code_snippet_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class CodeSnippetFile < ActiveRecord::Base
end
