class CreateMonthExchangeRates < ActiveRecord::Migration
  def change
    create_table :month_exchange_rates do |t|
      t.references :business, null: false

      t.date :ref_date, null: false

      t.string :source_currency_code, null: false
      t.string :target_currency_code, null: false
      t.decimal :conversion_rate, precision: 8, scale: 5, default: 1.0, null: false

      t.timestamps null: false
    end
  end
end
