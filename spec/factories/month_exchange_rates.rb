FactoryBot.define do
  factory :month_exchange_rate do
    ref_date { Date.today }
    business
    from_currency_id { "USD" }
    to_currency_id { "ARS" }
    conversion_rate { 200 }
  end
end
