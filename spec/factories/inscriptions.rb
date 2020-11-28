# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :inscription do
    business
    contact {FactoryBot.create(:contact, :business => self.business)}
    value {100}
  end
end
