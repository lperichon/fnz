class AddExternalIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :external_id, :integer
  end
end
