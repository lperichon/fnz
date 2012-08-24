class CreateTransactions < ActiveRecord::Migration
  def change
    create_table(:transactions) do |t|
      t.string :type,                     :null => false
      t.string :description,              :null => false, :default => ""
      t.references :business
      t.integer :source_id,               :null => false
      t.decimal :amount,                  :null => false, :precision => 8, :scale => 2
    end
  end
end
