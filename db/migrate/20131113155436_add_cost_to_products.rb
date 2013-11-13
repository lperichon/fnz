class AddCostToProducts < ActiveRecord::Migration
  def change
    rename_column :products, :currency, :price_currency
    add_column :products, :cost, :decimal, :null => false, :precision => 8, :scale => 2, :default => 0
    add_column :products, :cost_currency, :string
  end
end
