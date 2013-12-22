class AddTypeToImports < ActiveRecord::Migration
  def change
    add_column :imports, :type, :string
  end
end