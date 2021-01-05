require 'rails_helper'

describe SantanderRioArImport do
  
  before(:each) do
    @business = FactoryBot.create(:school)
    @attr = {
      :upload => Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/santander.xls'), 'application/xls'),
      :business_id => @business.id,
      :account_id => @business.accounts.first.id,
      :status => :ready
    }

    User.current_user = @business.owner
  end

  it "should process an xls file" do
    import = SantanderRioArImport.create(@attr)
    expect {
      import.process
    }.to change(Transaction, :count).by(3)
    import.status.should == :finished
  end


  it "should update transactions already imported" do
    import = SantanderRioArImport.create(@attr)
    import.process
    expect {
      import.process
    }.not_to change(Transaction, :count)
    import.status.should == :finished
  end

end