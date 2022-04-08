class ReceiptHmTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :receipt_id, :integer
    add_index :transactions, :receipt_id
    Receipt.all.each do |r|
      r.trans.update_columns(receipt_id: r.id)
    end
    remove_column :receipts, :transaction_id
  end
end
