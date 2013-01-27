class AddPadmaIdToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :padma_id, :string
  end
end
