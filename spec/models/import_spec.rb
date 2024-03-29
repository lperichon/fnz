require 'rails_helper'

describe Import do
  
  before(:each) do
    @business = FactoryBot.create(:business)
    @attr = {
      :upload => Rack::Test::UploadedFile.new('spec/fixtures/empty_transactions.csv', 'text/csv'),
      :business_id => @business.id
    }

    User.current_user = @business.owner
  end
  
  it "should create a new instance given a valid attribute" do
    Import.create!(@attr)
  end

  it "should require a business" do
    no_business_import = Import.new(@attr.merge(:business_id => nil))
    expect(no_business_import).not_to be_valid
  end

  it { should have_attached_file(:upload) }
  it { should validate_attachment_presence(:upload) }
  xit { should validate_attachment_content_type(:upload).
                  allowing('text/csv').
                  rejecting('image/png', 'image/gif') }

  it "should process a csv file" do
    import = TransactionImport.create(@attr)
    allow(import.upload).to receive(:path).and_return("#{Rails.root}/spec/fixtures/transactions.csv")
    expect {
      import.process
    }.to change(Transaction, :count).by(1)
    expect(import.status).to eq :finished
  end

  it "defaults status to ready" do
    i = Import.create(@attr.merge(:status => nil))
    expect(i.status).to eq :ready
  end


end
