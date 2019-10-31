# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transaction do
    type "Debit"
    description 'Test Transaction'
    amount 3.5
    business
    creator { FactoryGirl.create(:user) }
    transaction_at { Time.now }
    source
  end
end
