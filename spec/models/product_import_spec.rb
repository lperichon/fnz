require 'spec_helper'

describe Import do
  
  before(:each) do
    @business = FactoryGirl.create(:business)
    @attr = {
      :upload => Rack::Test::UploadedFile.new('spec/fixtures/empty_productos.csv', 'text/csv'),
      :business_id => @business.id
    }

    User.current_user = @business.owner
  end

  it "should process a csv file" do
    import = ProductImport.create(@attr)
    import.upload.stub(:path).and_return("#{Rails.root}/spec/fixtures/belgrano_productos.csv")
    expect {
      import.process
    }.to change(Product, :count).by(154)
    import.status.should == :finished
  end


end