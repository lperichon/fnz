class AddCreatorIdToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :creator_id, :integer
  end
end
