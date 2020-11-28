# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :account, :aliases => [:source] do
    name {'Test Account'}
    business { FactoryBot.create(:business) }
  end
end
