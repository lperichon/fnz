class IndexMembershipsAndInstallments < ActiveRecord::Migration
  def changed
    add_index :memberships, :contact_id
    add_index :installments, :membership_id
  end
end
