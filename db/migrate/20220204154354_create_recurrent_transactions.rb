class CreateRecurrentTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :recurrent_transaction_id, :integer
    create_table :recurrent_transactions do |t|

      t.references :business
      t.references :source
      t.references :target

      t.string :description

      t.string :type
      t.decimal :amount

      t.integer  "contact_id"
      t.integer  "agent_id"
      t.integer  "admpart_tag_id"

      t.timestamps null: false
    end
  end
end
