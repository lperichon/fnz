# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence :name do |n|
    "name#{n}"
  end

  factory :payment_type do
    name
    description "asdf"
    business
  end
end
