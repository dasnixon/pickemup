class AddDatabasesToTechStack < ActiveRecord::Migration
  def change
    add_column :tech_stacks, :nosql_databases, :string, array: true, default: []
    add_column :tech_stacks, :relational_databases, :string, array: true, default: []
  end
end
