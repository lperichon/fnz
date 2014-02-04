require 'spec_helper'

describe InstallmentImport do
  
  before(:each) do
    @business = FactoryGirl.create(:school)
    @attr = {
      :upload => Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/belgrano_tickets.csv'), 'text/csv'),
      :business_id => @business.id
    }
    membership = FactoryGirl.create(:membership, :business => @business)
    Membership.stub(:find_by_external_id).and_return(membership)
    agent = FactoryGirl.create(:agent, :business => @business, :padma_id => "homer.simpson")
    membership.contact.update_attribute(:padma_teacher, "homer.simpson")
    User.current_user = @business.owner
  end

  it "should process a csv file" do
    import = InstallmentImport.create(@attr)
    expect {
      import.process
    }.to change(Installment, :count).by(237)
    import.status.should == :finished
  end


  it "creates transactions" do
    import = InstallmentImport.create(@attr)
    expect {
      import.process
    }.to change(Transaction, :count).by(127)
    import.status.should == :finished
  end

end