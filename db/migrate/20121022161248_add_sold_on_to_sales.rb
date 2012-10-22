class AddSoldOnToSales < ActiveRecord::Migration
  def change
    add_column :sales, :sold_on, :date
  end
end
