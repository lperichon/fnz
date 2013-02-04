class AddPadmaIdToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :padma_id, :string
  end
end
