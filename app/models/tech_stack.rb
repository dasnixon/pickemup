# == Schema Information
#
# Table name: tech_stacks
#
#  id                  :integer          not null, primary key
#  company_id          :integer
#  name                :string(255)
#  back_end_languages  :string(255)      default([])
#  front_end_languages :string(255)      default([])
#  frameworks          :string(255)      default([])
#  dev_ops_tools       :string(255)      default([])
#  created_at          :datetime
#  updated_at          :datetime
#

class TechStack < ActiveRecord::Base
  include PreferenceConstants
  include PreferencesHelper

  HASHABLE_PARAMS = ['back_end_languages', 'front_end_languages', 'dev_ops_tools', 'frameworks']

  attr_accessible :name, :back_end_languages, :front_end_languages,
    :frameworks, :dev_ops_tools

  belongs_to :company

  def attribute_default_values(attr)
    self.class.const_get(attr.upcase)
  end
end
