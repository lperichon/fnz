require 'spec_helper'

describe Contact do
  
  before(:each) do
    @business = FactoryGirl.create(:business)
    @attr = { 
      :name => "Example Contact",
      :business_id => @business.id
    }
  end
  
  it "should create a new instance given a valid attribute" do
    Contact.create!(@attr)
  end
  
  it "should require a name" do
    no_name_contact = Contact.new(@attr.merge(:name => ""))
    no_name_contact.should_not be_valid
  end

  it "should require a business" do
    no_business_contact = Contact.new(@attr.merge(:business_id => nil))
    no_business_contact.should_not be_valid
  end

  describe "get_by_padma_id" do
    context "scoped to business" do
      let(:business){FactoryGirl.create(:business, padma_id: 'nunez')}
      let(:pid){'contact-id'}
      context "if contact exists" do
        let!(:contact){FactoryGirl.create(:contact, padma_id: pid, business_id: business.id)}
        it "returns it" do
          expect(business.contacts.get_by_padma_id(pid)).to eq contact
        end
        it "wont create a new one" do
          expect{business.contacts.get_by_padma_id(pid) }.not_to change{Contact.count}
        end
      end
      context "if contact doesnt exist" do
        before do
          PadmaContact.stub(:find).and_return(PadmaContact.new(id: pid,
                                                               first_name: 'Dwayne',
                                                               last_name: 'macgowan',
                                                               local_status: 'student',
                                                               local_teacher: 'daniel.fersztand'
                                                              ))
        end
        it "creates a new one" do
          expect{business.contacts.get_by_padma_id(pid) }.to change{Contact.count}.by(1)
        end
        it "returns contact" do
          c = business.contacts.get_by_padma_id(pid)
          expect(c).to be_a Contact
          expect(c.padma_id).to eq pid
        end
      end
    end
  end
end
