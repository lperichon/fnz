class AddTransactionsToImports < ActiveRecord::Migration
  def change
    create_table :imports_transactions do |t|
      t.references :import
      t.references :transaction
    end
  end
end
