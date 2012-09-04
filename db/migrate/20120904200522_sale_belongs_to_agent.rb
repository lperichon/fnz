class SaleBelongsToAgent < ActiveRecord::Migration
  def change
    add_column :sales, :agent_id, :integer
  end
end
