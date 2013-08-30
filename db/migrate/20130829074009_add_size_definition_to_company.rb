class AddSizeDefinitionToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :size_definition, :string
  end
end
