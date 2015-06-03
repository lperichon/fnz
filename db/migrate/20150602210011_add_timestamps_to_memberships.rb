class AddTimestampsToMemberships < ActiveRecord::Migration
  def change
    change_table :memberships do |t|
      t.timestamps
    end
  end
end
