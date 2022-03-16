require 'rails_helper'

describe 'Account::HasCurrency' do

  before(:each) do
    @business = FactoryBot.create(:business)
    @attr = {
      :name => "Example Account",
      :business_id => @business.id
    }
  end

  it "defaults currency to business's currency" do
    b = FactoryBot.create(:business, currency_code: "ars")
    a = FactoryBot.build(:account, business_id: b.id)
    a.save
    expect(a.currency.iso_code.downcase).to eq b.currency_code.downcase
  end
end
