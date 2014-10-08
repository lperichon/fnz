require 'spec_helper'

describe MembershipSearch do
  describe "persisted?" do
    let(:ms){MembershipSearch.new}
    it "returns false" do
      expect(ms).not_to be_persisted
    end
  end

  context "with ends_after: 2014-1-1" do
    let(:ms_attributes){{ends_after: Date.civil(2014,1,1)}}
    let(:ms){MembershipSearch.new(ms_attributes)}

    describe "#results" do
      let!(:yes){FactoryGirl.create(:membership,
                                    begins_on: Date.civil(2014,1,1),
                                    ends_on: Date.civil(2014,2,1))}
      let!(:no){FactoryGirl.create(:membership,
                                   begins_on: Date.civil(2013,1,1),
                                   ends_on: Date.civil(2013,2,1))}
      it "includes membership ending on 2014-2-1" do
        expect(ms.results).to include yes
      end
      it "wont include membership ending on 2013-2-1" do
        expect(ms.results).not_to include no
      end
    end
  end
end
