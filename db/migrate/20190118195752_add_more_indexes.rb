class AddMoreIndexes < ActiveRecord::Migration
  def change
    add_index :installments, :agent_id
  end
end
