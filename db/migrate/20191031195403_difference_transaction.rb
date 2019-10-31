class DifferenceTransaction < ActiveRecord::Migration
  def change
    add_column :balance_checks, :difference_transaction_id, :integer
  end
end
