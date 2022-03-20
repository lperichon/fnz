class RenameCurrenciesToId < ActiveRecord::Migration
  def change
    rename_column :month_exchange_rates, :source_currency_code, :from_currency_id
    rename_column :month_exchange_rates, :target_currency_code, :to_currency_id
  end
end
