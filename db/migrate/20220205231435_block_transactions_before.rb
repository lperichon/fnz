class BlockTransactionsBefore < ActiveRecord::Migration
  def change
    add_column :businesses, :block_transactions_before, :datetime
  end
end
