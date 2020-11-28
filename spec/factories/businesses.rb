# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :business do
    name {'Test Business'}
    owner { FactoryBot.create(:user) }
  end

  factory :school do
    name {'Test School'}
    type {'School'}
    owner
  end

  factory :event do
    name {'Test Event'}
    type {'Event'}
    owner
  end
end
