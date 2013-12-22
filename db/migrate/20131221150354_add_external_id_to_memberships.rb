class AddExternalIdToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :external_id, :integer
  end
end
