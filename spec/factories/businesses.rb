# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :business do
    name 'Test Business'
    owner
  end

  factory :school do
    name 'Test School'
    type 'School'
    owner
  end

  factory :event do
    name 'Test Event'
    type 'Event'
    owner
  end
end