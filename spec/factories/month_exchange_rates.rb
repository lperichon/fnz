FactoryBot.define do
  factory :month_exchange_rate do
    ref_date { Date.today }
    business
    source_currency_code { "USD" }
    target_currency_code { "ARS" }
    conversion_rate { 200 }
  end
end
