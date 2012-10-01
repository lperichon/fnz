class AddErrorsToImports < ActiveRecord::Migration
  def change
    add_column :imports, :errors_csv, :text
  end
end
