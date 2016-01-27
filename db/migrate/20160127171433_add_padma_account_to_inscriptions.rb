class AddPadmaAccountToInscriptions < ActiveRecord::Migration
  def change
  	add_column :inscriptions, :padma_account, :string
  end
end
