require 'rails_helper'

describe Business do
  
  before(:each) do
    @user = FactoryBot.create(:user)
    @attr = { 
      :name => "Example Business",
      :owner_id => @user.id
    }
  end

  it "should create a new instance given a valid attribute" do
    Business.create!(@attr)
  end
  
  it "should require a name" do
    no_name_business = Business.new(@attr.merge(:name => ""))
    expect(no_name_business).not_to be_valid
  end

  it "should require an owner" do
    no_owner_business = Business.new(@attr.merge(:owner_id => nil))
    expect(no_owner_business).not_to be_valid
  end

  describe "has payment types" do
    it { should have_many :payment_types }
  end

end
