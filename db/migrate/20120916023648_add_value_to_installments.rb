class AddValueToInstallments < ActiveRecord::Migration
  def change
    add_column :installments, :value, :decimal, :null => false, :precision => 8, :scale => 2, :default => 0
  end
end
