# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :inscription do
    business
    contact {FactoryGirl.create(:contact, :business => self.business)}
    value 100
  end
end