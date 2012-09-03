class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :name,              :null => false, :default => "Unknown"
      t.references :business
    end
  end
end
