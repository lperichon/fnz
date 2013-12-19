class CreateMembershipImportsMemberships < ActiveRecord::Migration
  def change
    create_table :membership_imports_memberships do |t|
      t.references :membership_import
      t.references :membership
    end
  end
end
