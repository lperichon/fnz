class AddShowOnMenuToUsersBusinesses < ActiveRecord::Migration
  def change
  	add_column :businesses_users, :show_on_menu, :boolean, default: true
  end
end
