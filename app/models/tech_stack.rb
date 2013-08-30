# == Schema Information
#
# Table name: tech_stacks
#
#  id                   :uuid             not null, primary key
#  company_id           :uuid
#  name                 :string(255)
#  back_end_languages   :string(255)      default([])
#  front_end_languages  :string(255)      default([])
#  frameworks           :string(255)      default([])
#  dev_ops_tools        :string(255)      default([])
#  created_at           :datetime
#  updated_at           :datetime
#  nosql_databases      :string(255)      default([])
#  relational_databases :string(255)      default([])
#

class TechStack < ActiveRecord::Base
  include PreferenceConstants
  include PreferencesHelper

  HASHABLE_PARAMS = ['back_end_languages', 'front_end_languages', 'dev_ops_tools', 'frameworks', 'relational_databases', 'nosql_databases']

  belongs_to :company
  has_many :job_listings

  def attribute_default_values(attr)
    self.class.const_get(attr.upcase)
  end
end
