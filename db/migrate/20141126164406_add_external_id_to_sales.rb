class AddExternalIdToSales < ActiveRecord::Migration
  def change
  	add_column :sales, :external_id, :integer
  end
end
