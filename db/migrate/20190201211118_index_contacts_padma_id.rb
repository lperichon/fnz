class IndexContactsPadmaId < ActiveRecord::Migration
  def change
    remove_index :contacts, :business_id
    add_index :contacts, [:business_id, :padma_id]
  end
end
