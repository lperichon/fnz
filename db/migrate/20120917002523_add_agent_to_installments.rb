class AddAgentToInstallments < ActiveRecord::Migration
  def change
    add_column :installments, :agent_id, :integer
  end
end
