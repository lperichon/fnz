class RemoveUsersTimezone < ActiveRecord::Migration
  def change
    remove_column :users, :time_zone
  end
end
