class ChangeConversionRatePrecision < ActiveRecord::Migration
  def change
    change_column :month_exchange_rates, :conversion_rate, :decimal, precision: 20, scale: 8
    change_column :transactions, :conversion_rate, :decimal, precision: 20, scale: 8
  end
end
