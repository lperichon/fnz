class BusinessCurrency < ActiveRecord::Migration
  def change
    add_column :businesses, :currency, :string
  end
end
