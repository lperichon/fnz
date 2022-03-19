# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :transaction do
    type {"Debit"}
    description {'Test Transaction'}
    amount {3.5}
    business
    creator { FactoryBot.create(:user) }
    transaction_at { Time.now }
    source
  end

  factory :credit do
    description {'Test Transaction'}
    amount_cents {3.5}
    business
    creator { FactoryBot.create(:user) }
    transaction_at { Time.now }
    source
  end
end
