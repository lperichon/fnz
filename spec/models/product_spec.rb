require 'spec_helper'

describe Product do
  
  before(:each) do
    @business = FactoryGirl.create(:business)
    @attr = { 
      :name => "Example Product",
      :business_id => @business.id,
      :price => 3.2,
      :price_currency => :usd
    }
  end
  
  it "should create a new instance given a valid attribute" do
    Product.create!(FactoryGirl.attributes_for(:product, :business_id => @business.id))
  end
  
  it "should require a name" do
    no_name_product = Product.new(FactoryGirl.attributes_for(:product, :business => @business, :name => ""))
    no_name_product.should_not be_valid
  end

  it "should require a business" do
    no_business_product = Product.new(FactoryGirl.attributes_for(:product, :business => nil))
    no_business_product.should_not be_valid
  end


  it "should require a price" do
    no_price_product = Product.new(FactoryGirl.attributes_for(:product, :business => @business, :price => nil))
    no_price_product.should_not be_valid
  end

  it "should require a cost" do
    no_cost_product = Product.new(FactoryGirl.attributes_for(:product, :business => @business, :cost => nil))
    no_cost_product.should_not be_valid
  end

end