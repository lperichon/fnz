require 'rails_helper'

describe SaleImport do
  
  before(:each) do
    @business = FactoryBot.create(:school)
    @attr = {
      :upload => Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/belgrano_ventas.csv'), 'text/csv'),
      :business_id => @business.id,
      :status => :ready
    }

    User.current_user = @business.owner
  end

  it "should process a csv file" do
    import = SaleImport.create(@attr)
    expect {
      import.process
    }.to change(Sale, :count).by(198)
    expect(import.status).to eq :finished
  end


end
