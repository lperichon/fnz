require 'spec_helper'

describe MembershipImport do
  
  before(:each) do
    @business = FactoryGirl.create(:business)
    @attr = {
      :upload => Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/belgrano_plans.csv'), 'text/csv'),
      :business_id => @business.id
    }

    User.current_user = @business.owner
  end

  it "should process a csv file" do
    import = MembershipImport.create(@attr)
    expect {
      import.process
    }.to change(Membership, :count).by(1129)
    import.status.should == :finished
  end


end