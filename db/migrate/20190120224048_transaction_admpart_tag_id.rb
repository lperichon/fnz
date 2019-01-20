class TransactionAdmpartTagId < ActiveRecord::Migration
  def change
    add_column :transactions, :admpart_tag_id, :integer
    add_index :transactions, [:business_id, :admpart_tag_id]
  end
end
