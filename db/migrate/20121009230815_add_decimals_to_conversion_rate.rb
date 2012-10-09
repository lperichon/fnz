class AddDecimalsToConversionRate < ActiveRecord::Migration
  def up
    change_column :transactions, :conversion_rate, :decimal, :null => false, :precision => 8, :scale => 5, :default => 1
  end

  def down
    change_column :transactions, :conversion_rate, :decimal, :null => false, :precision => 8, :scale => 2, :default => 1
  end
end
