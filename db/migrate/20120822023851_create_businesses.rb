class CreateBusinesses < ActiveRecord::Migration
  def change
    create_table(:businesses) do |t|
      t.string :name,              :null => false, :default => ""
      t.integer :owner_id,         :null => false
      t.timestamps
    end
  end
end
