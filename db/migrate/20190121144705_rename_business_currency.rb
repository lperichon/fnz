class RenameBusinessCurrency < ActiveRecord::Migration
  def change
    rename_column :businesses, :currency, :currency_code
  end
end
