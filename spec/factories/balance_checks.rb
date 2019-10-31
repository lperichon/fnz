# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :balance_check do
    checked_at { Time.now }
    creator { FactoryGirl.create(:user) }
    account
  end
end
