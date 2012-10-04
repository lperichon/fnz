class AddClosedOnToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :closed_on, :date
  end
end
