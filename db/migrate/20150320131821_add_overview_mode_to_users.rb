class AddOverviewModeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :overview_mode, :string, :default => 'table'
  end
end
