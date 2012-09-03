class AddTypeToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :type, :string, :default => "Personal"
  end
end
