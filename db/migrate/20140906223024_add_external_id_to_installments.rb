class AddExternalIdToInstallments < ActiveRecord::Migration
  def change
    add_column :installments, :external_id, :integer
  end
end
