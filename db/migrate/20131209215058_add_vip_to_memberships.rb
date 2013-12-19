class AddVipToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :vip, :boolean
  end
end
