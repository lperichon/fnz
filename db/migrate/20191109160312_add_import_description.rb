class AddImportDescription < ActiveRecord::Migration
  def change
    add_column :imports, :description, :string
  end
end
