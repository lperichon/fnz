class AddStatusToInstallments < ActiveRecord::Migration
  def change
    add_column :installments, :status, :string
  end
end
