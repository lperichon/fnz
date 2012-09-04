class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name,              :null => false, :default => "Unknown"
      t.decimal :price,          :null => false, :precision => 8, :scale => 2, :default => 0
      t.string :currency
      t.references :business
    end
  end
end
