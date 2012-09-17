class AddValueToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :value, :decimal, :null => false, :precision => 8, :scale => 2, :default => 0
  end
end
