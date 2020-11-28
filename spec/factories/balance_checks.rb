# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :balance_check do
    checked_at { Time.now }
    creator { FactoryBot.create(:user) }
    account
  end
end
