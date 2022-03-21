class AccountsBalanceBigint < ActiveRecord::Migration
  def change
    change_column :accounts, :balance_cents, :bigint
  end
end
