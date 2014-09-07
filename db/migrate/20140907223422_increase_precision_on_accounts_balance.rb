class IncreasePrecisionOnAccountsBalance < ActiveRecord::Migration
  def change
  	change_column :accounts, :balance, :decimal, precision: 12, scale: 2
  end
end
