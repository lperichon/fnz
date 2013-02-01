class AddPadmaStatusToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :padma_status, :string
    add_timestamps :contacts
  end
end
