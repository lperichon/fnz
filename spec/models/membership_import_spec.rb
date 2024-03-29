require 'rails_helper'

describe MembershipImport do
  
  before(:each) do
    @business = FactoryBot.create(:business)
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
    expect(import.status).to eq :finished
  end


end
