# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transaction do
    description 'Test Transaction'
    amount 3.5
    business
    source
  end
end