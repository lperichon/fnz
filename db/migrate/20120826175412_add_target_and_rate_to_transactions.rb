class AddTargetAndRateToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :target_id, :integer
    add_column :transactions, :conversion_rate, :decimal, :null => false, :precision => 8, :scale => 2, :default => 1
  end
end
