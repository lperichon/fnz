class AddDateToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :transaction_at, :datetime
  end
end
