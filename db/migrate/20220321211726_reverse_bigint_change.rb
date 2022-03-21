class ReverseBigintChange < ActiveRecord::Migration
  def change
    change_column :accounts, :balance_cents, :integer
  end
end
