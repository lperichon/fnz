require 'spec_helper'

describe Product do
  
  before(:each) do
    @business = FactoryGirl.create(:business)
    @attr = { 
      :name => "Example Product",
      :business_id => @business.id,
      :price => 3.2,
      :currency => :usd
    }
  end
  
  it "should create a new instance given a valid attribute" do
    Product.create!(@attr)
  end
  
  it "should require a name" do
    no_name_product = Product.new(@attr.merge(:name => ""))
    no_name_product.should_not be_valid
  end

  it "should require a business" do
    no_business_product = Product.new(@attr.merge(:business_id => nil))
    no_business_product.should_not be_valid
  end


  it "should require a price" do
    no_price_product = Product.new(@attr.merge(:price => nil))
    no_price_product.should_not be_valid
  end

end