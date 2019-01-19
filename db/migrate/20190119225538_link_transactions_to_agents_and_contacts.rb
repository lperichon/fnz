class LinkTransactionsToAgentsAndContacts < ActiveRecord::Migration
  def change
    add_column :transactions, :contact_id, :integer
    add_column :transactions, :agent_id, :integer
  end
end
