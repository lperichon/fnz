class AddBalanceToInstallments < ActiveRecord::Migration
  def change
    add_column :installments, :balance, :decimal, :null => false, :precision => 8, :scale => 2, :default => 0
  end
end
