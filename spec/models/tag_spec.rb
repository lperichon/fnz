require 'spec_helper'

describe Tag do
  
  let(:business){ FactoryGirl.create(:business) }

  before(:each) do
    @attr = { 
      :name => "Example Tag",
      :business_id => business.id
    }
  end
  
  it "should create a new instance given a valid attribute" do
    Tag.create!(@attr)
  end
  
  it "should require a name" do
    no_name_tag = Tag.new(@attr.merge(:name => ""))
    no_name_tag.should_not be_valid
  end

  it "should require a business" do
    no_business_tag = Tag.new(@attr.merge(:business_id => nil))
    no_business_tag.should_not be_valid
  end

  describe ".get_installments_tag" do
    describe "if installment_tag exists" do
      let!(:itag){ FactoryGirl.create(:tag, system_name: "installment", business_id: business.id) }
      it "returns scope's installment tag" do
        expect(business.tags.get_installments_tag).to eq itag
      end
    end
    describe "if installment_tag doesnt exist" do
      it "creates it respecting scope" do
        expect{ business.tags.get_installments_tag }.to change{ Tag.count }
        expect(business.tags.get_installments_tag.business_id).to eq business.id
                
      end
    end
  end

  it "prevents system tags from being destroyed" do
    t = business.tags.get_sales_tag
    expect{ t.destroy }.not_to change{ Tag.count }
    expect(Tag.find(t.id)).to eq t
  end


end
