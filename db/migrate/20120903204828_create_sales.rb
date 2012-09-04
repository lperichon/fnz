class CreateSales < ActiveRecord::Migration
  def change
    create_table :sales do |t|
      t.references :business
      t.references :contact
    end

    create_table :sales_transactions do |t|
      t.references :sale
      t.references :transaction
    end
  end
end
