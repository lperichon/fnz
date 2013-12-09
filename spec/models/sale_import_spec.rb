require 'spec_helper'

describe SaleImport do
  
  before(:each) do
    @business = FactoryGirl.create(:business)
    @attr = {
      :upload => Rack::Test::UploadedFile.new('spec/fixtures/empty_ventas.csv', 'text/csv'),
      :business_id => @business.id
    }

    User.current_user = @business.owner
  end

  it "should process a csv file" do
    import = SaleImport.create(@attr)
    import.upload.stub(:path).and_return("#{Rails.root}/spec/fixtures/belgrano_ventas.csv")
    expect {
      import.process
    }.to change(Sale, :count).by(198)
    import.status.should == :finished
  end


end