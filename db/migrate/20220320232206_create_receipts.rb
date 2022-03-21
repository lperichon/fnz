class CreateReceipts < ActiveRecord::Migration
  def change
    create_table :receipts do |t|

      t.references :business

      t.references :transaction

      t.references :contact
      t.string :email

      t.string :description
      t.integer :amount_cents
      t.string :currency_id

      t.date   :ref_date

      t.string :url_secret

      t.timestamps null: false
    end
  end
end
