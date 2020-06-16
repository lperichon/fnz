class CreateTransactionRules < ActiveRecord::Migration
  def change
    create_table :transaction_rules do |t|
      t.string :operator
      t.string :value

      t.integer :contact_id
      t.integer :agent_id
      t.integer :admpart_tag_id

      t.integer :business_id

      t.timestamps
    end
  end
end
