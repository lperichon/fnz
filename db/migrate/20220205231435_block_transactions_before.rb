class BlockTransactionsBefore < ActiveRecord::Migration
  def change
    add_column :businesses, :block_transactions_before, :datetime
    Business.update_all block_transactions_before: 1.year.ago
  end
end
