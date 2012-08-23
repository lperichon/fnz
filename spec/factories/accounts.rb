# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :accounts do
    name 'Test Account'
    business
  end
end