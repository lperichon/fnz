class CreatePaymentTypes < ActiveRecord::Migration
  def change
    create_table :payment_types do |t|
      t.string :name
      t.text   :description
      t.references :business
      t.timestamps
    end
  end
end
