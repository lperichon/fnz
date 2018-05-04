class AddExternalIdToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :external_id, :string
  end
end
