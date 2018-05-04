class AddAccountToImports < ActiveRecord::Migration
  def change
  	add_column :imports, :account_id, :integer, references: :accounts
  end
end
