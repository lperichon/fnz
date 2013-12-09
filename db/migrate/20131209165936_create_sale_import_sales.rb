class CreateSaleImportSales < ActiveRecord::Migration
  def change
    create_table :sale_imports_sales do |t|
      t.references :sale_import
      t.references :sale
    end
  end
end
