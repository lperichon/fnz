# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :product do
    business
    name {"Example Product"}
    price {3.2}
    price_currency {:usd}
    cost {1}
    cost_currency {:usd}
    stock {10}
  end
end
