# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product do
    business
    name "Example Product"
    price 3.2
    price_currency :usd
    cost 1
    cost_currency :usd
  end
end