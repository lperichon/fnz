class CreateProductImportsProducts < ActiveRecord::Migration
  def change
    create_table :product_imports_products do |t|
      t.references :product_import
      t.references :product
    end
  end

end
