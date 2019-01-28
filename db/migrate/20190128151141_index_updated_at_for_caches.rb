class IndexUpdatedAtForCaches < ActiveRecord::Migration
  def change
    add_column :installments, :created_at, :timestamp
    add_column :installments, :updated_at, :timestamp
    add_column :transactions, :created_at, :timestamp
    add_column :transactions, :updated_at, :timestamp

    add_index :installments, [:membership_id, :updated_at]
    add_index :transactions, [:business_id, :updated_at]
  end
end
