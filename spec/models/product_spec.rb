require 'spec_helper'

describe Product do
  
  before(:each) do
    @business = FactoryBot.create(:business)
    @attr = { 
      :name => "Example Product",
      :business_id => @business.id,
      :price => 3.2,
      :price_currency => :usd
    }
  end
  
  it "should create a new instance given a valid attribute" do
    Product.create!(FactoryBot.attributes_for(:product, :business_id => @business.id))
  end
  
  it "should require a name" do
    no_name_product = Product.new(FactoryBot.attributes_for(:product, :business_id => @business.id, :name => ""))
    no_name_product.should_not be_valid
  end

  it "should require a business" do
    no_business_product = Product.new(FactoryBot.attributes_for(:product, :business_id => nil))
    no_business_product.should_not be_valid
  end


  it "should require a price" do
    no_price_product = Product.new(FactoryBot.attributes_for(:product, :business_id => @business.id, :price => nil))
    no_price_product.should_not be_valid
  end

  it "should require a cost" do
    no_cost_product = Product.new(FactoryBot.attributes_for(:product, :business_id => @business.id, :cost => nil))
    no_cost_product.should_not be_valid
  end

  it "should require a positive stock" do
    no_stock_product = Product.new(FactoryBot.attributes_for(:product, :business_id => @business.id, :stock => -1))
    no_stock_product.should_not be_valid
  end

  it "should allow stock to reach 0" do
    no_stock_product = Product.new(FactoryBot.attributes_for(:product, :business_id => @business.id, :stock => 0))
    no_stock_product.should be_valid
  end

  it "should scope hidden products" do
    FactoryBot.create(:product, :business_id => @business.id, :hidden => true)
    Product.hidden.count.should equal(1)
  end

end