require 'rails_helper'

describe GaliciaOfficeArImport do
  
  before(:each) do
    @business = FactoryBot.create(:school)
    @attr = {
      :upload => Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/galicia-office-8feb2023.csv'), 'application/csv'),
      :business_id => @business.id,
      :account_id => @business.accounts.first.id,
      :status => :ready
    }

    User.current_user = @business.owner
  end

  describe "process" do
    it "should create transactions" do
      galicia_office_ar_import = GaliciaOfficeArImport.create!(@attr)
      galicia_office_ar_import.process
      expect(galicia_office_ar_import.imported_records.count).to eq 26
      first_transaction = galicia_office_ar_import.imported_records.first
      expect(first_transaction).to be_a(Debit)
      expect(first_transaction.amount_cents).to eq 562500
      expect(first_transaction.description).to eq "Comision Mantenimiento Cta. Cte/cce - Diciembre 2022"
    end
  end

end
