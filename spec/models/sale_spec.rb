require 'rails_helper'

describe Sale do
  
  before(:each) do
    allow(PadmaContact).to receive(:find).and_return(PadmaContact.new(:first_name => "Homer", :last_name => "Simpson"))
    allow_any_instance_of(Contact).to receive(:padma).and_return([PadmaContact.new(:first_name => "Homer", :last_name => "Simpson")])
    @business = FactoryBot.create(:business)
    @contact = FactoryBot.create(:contact, :business => @business)
    @agent = FactoryBot.create(:agent, :business => @business)
    @attr = {
      :contact_id => @contact.id,
      :business_id => @business.id,
      :agent_id => @agent.id,
      :sold_on => Date.today
    }
  end

  it "should create a new instance given a valid attribute" do
    Sale.create!(@attr)
  end


  it "should require a business" do
    no_business_sale = Sale.new(@attr.merge(:business_id => nil))
    expect(no_business_sale).not_to be_valid
  end

  it "should create a new contact if necessary" do
    sale_with_padma_contact = Sale.create!(@attr.merge(:contact_id => nil, :padma_contact_id => "1234"))
    expect(sale_with_padma_contact.contact).not_to be_nil
  end


  describe "#build_from_csv" do
  	describe "with a paid sale" do
  		before do
  			row = ['50025','50015','juan.abraham','50182','','2008-11-03','2008-11-03 20:19:46 UTC','2010-03-12 03:33:32 UTC','2700','2008-11-03','true','1','ARS','']
  			@business = FactoryBot.create(:school)
  			@product = FactoryBot.create(:product, :business => @business, :external_id => row[1].to_i)
  			@sale = Sale.build_from_csv(@business, row)
  		end

  		it "should create a valid sale" do
        expect(@sale).to be_valid
  		end

  		it "should create a payment transaction" do
  			expect {
				@sale.save		       
		      }.to change{Transaction.count}.by(1)
  		end
  	end

  	describe "with an unpaid sale" do
  		before do
  			row = ['50014','50015','guido.morando','50002','','2008-10-27','2008-10-27 18:13:42 UTC','2010-03-12 03:33:32 UTC','2700','','false','1','ARS','']
  			@business = FactoryBot.create(:school)
  			@product = FactoryBot.create(:product, :business => @business, :external_id => row[1].to_i)
  			@sale = Sale.build_from_csv(@business, row)
  		end

  		it "should create a valid sale" do
        expect(@sale).to be_valid
  		end

  		it "should not create a payment transaction" do
  			expect {
				@sale.save		       
		    }.to_not change{Transaction.count}
  		end
  	end
  end

end
