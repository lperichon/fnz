class AddStateToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :state, :string
    add_column :transactions, :reconciled_at, :datetime
  end
end
