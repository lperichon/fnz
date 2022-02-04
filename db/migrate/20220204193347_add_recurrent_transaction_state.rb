class AddRecurrentTransactionState < ActiveRecord::Migration
  def change
    add_column :recurrent_transactions, :state, :string
  end
end
