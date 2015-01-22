require 'spec_helper'

describe MembershipSearch do
  describe "persisted?" do
    let(:ms){MembershipSearch.new}
    it "returns false" do
      expect(ms).not_to be_persisted
    end
  end

  context "with business_id" do
    let(:business){FactoryGirl.create(:business)}
    let(:ms_att){{business_id: business.id}}
    let(:ms){MembershipSearch.new(ms_att)}

    let(:my_mem){FactoryGirl.create(:membership, business: business)}
    let(:other_mem){FactoryGirl.create(:membership)}

    it "includes membreship of business" do
      expect(ms.results).to include my_mem
    end
    it "excludes membership of other business" do
      expect(ms.results).not_to include other_mem
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
      it "wont include membership ending on 2014-2-1 but closed on 2013-2-1" do
        closed = FactoryGirl.create(:membership,
                                    begins_on: Date.civil(2013,1,1),
                                    ends_on: Date.civil(2014,2,1),
                                    closed_on: Date.civil(2013,2,1))
        expect(ms.results).not_to include closed
      end
      it "includes membership closed on 2014-2-1" do
        closed = FactoryGirl.create(:membership,
                                    begins_on: Date.civil(2013,1,1),
                                    ends_on: Date.civil(2014,3,1),
                                    closed_on: Date.civil(2014,2,1))
        expect(ms.results).to include closed
      end
    end
  end

  context "with payment_type_id" do
    let(:payment_type_id){'payment_type_id'}
    let(:ms_att){{payment_type_id: payment_type_id}}
    let(:ms){MembershipSearch.new(ms_att)}

    let(:my_mem){FactoryGirl.create(:membership, payment_type_id: 'payment_type_id')}
    let(:other_mem){FactoryGirl.create(:membership)}

    it "includes membreship of payment type" do
      expect(ms.results).to include my_mem
    end
    it "excludes membership of other payment_type" do
      expect(ms.results).not_to include other_mem
    end
  end

  context "with payment_type all" do
    let(:payment_type){'all'}
    let(:ms_att){{payment_type_id: payment_type}}
    let(:ms){MembershipSearch.new(ms_att)}

    let(:my_mem){FactoryGirl.create(:membership, payment_type_id: 'payment_type_1')}
    let(:other_mem){FactoryGirl.create(:membership, payment_type_id: 'payment_type_2')}

    it "includes membreship of all payment type" do
      expect(ms.results).to include my_mem
      expect(ms.results).to include other_mem
    end
  end

  context "with status: due" do
    let(:ms_attributes){{status: "due"}}
    let(:ms){MembershipSearch.new(ms_attributes)}

    describe "#results" do
      let!(:yes){FactoryGirl.create(:membership,
                                    begins_on: 6.months.ago.beginning_of_month,
                                    ends_on: Date.today.end_of_month)}
      let!(:no_active){FactoryGirl.create(:membership,
                                   begins_on: 5.months.ago.beginning_of_month,
                                   ends_on: 1.month.from_now.end_of_month)}
      let!(:no_overdue){FactoryGirl.create(:membership,
                                   begins_on: 7.months.ago.beginning_of_month,
                                   ends_on: 1.month.ago.end_of_month)}
      let!(:no_closed){FactoryGirl.create(:membership,
                                    begins_on: 6.months.ago.beginning_of_month,
                                    ends_on: Date.today.end_of_month,
                                    closed_on: 1.month.ago.end_of_month)}
      it "includes membership due this month" do
        expect(ms.results).to include yes
      end
      it "wont include membership finishing next month" do
        expect(ms.results).not_to include no_active
      end
      it "wont include membership finished last month" do
        expect(ms.results).not_to include no_overdue
      end
      it "wont include membership ending this month but closed on last month" do
        expect(ms.results).not_to include no_closed
      end
    end
  end
end
