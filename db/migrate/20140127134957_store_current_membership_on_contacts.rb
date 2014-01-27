class StoreCurrentMembershipOnContacts < ActiveRecord::Migration
  def change
  	add_column :contacts, :current_membership_id, :integer
  end
end
