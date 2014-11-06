class AddDisabledToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :disabled, :boolean, :default => false
  end
end
