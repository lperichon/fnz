require 'rails_helper'

describe ContactSearch do
  describe "persisted?" do
    let(:cs){ContactSearch.new}
    it "returns false" do
      expect(cs).not_to be_persisted
    end
  end

  context "with business_id" do
    let(:business){FactoryBot.create(:business)}
    let(:cs_att){{business_id: business.id}}
    let(:cs){ContactSearch.new(cs_att)}

    let(:my_contact){FactoryBot.create(:contact, business: business)}
    let(:other_contact){FactoryBot.create(:contact)}

    it "includes contact of business" do
      expect(cs.results).to include my_contact
    end
    it "excludes contact of other business" do
      expect(cs.results).not_to include other_contact
    end
  end

  context "with membership_payment_type_id" do
    let(:payment_type_id){'payment_type_id'}
    let(:cs){ContactSearch.new(cs_att)}
    let!(:my_mem){FactoryBot.create(:membership, payment_type_id: 'payment_type_id')}
    let!(:other_mem){FactoryBot.create(:membership)}
    describe "string" do
      let(:cs_att){{membership_payment_type_id: payment_type_id}}

      it "includes membreship of payment type" do
        expect(cs.results).to include my_mem.contact
      end
      it "excludes membership of other payment_type" do
        expect(cs.results).not_to include other_mem.contact
      end
    end
    describe "array" do
      describe "['']" do
        let(:cs_att){{membership_payment_type_id: [""]}}
        it "includes membreship of payment type" do
          expect(cs.results).to include my_mem.contact
        end
        it "includes membership of other payment_type" do
          expect(cs.results).to include other_mem.contact
        end
      end
      describe "[value]" do
        let(:cs_att){{membership_payment_type_id: [payment_type_id]}}
        it "includes membreship of payment type" do
          expect(cs.results).to include my_mem.contact
        end
        it "excludes membership of other payment_type" do
          expect(cs.results).not_to include other_mem.contact
        end
      end
    end
  end

  context "with payment_type all" do
    let(:payment_type){'all'}
    let(:cs_att){{membership_payment_type_id: payment_type}}
    let(:cs){ContactSearch.new(cs_att)}

    let(:my_mem){FactoryBot.create(:membership, payment_type_id: 'payment_type_1')}
    let(:other_mem){FactoryBot.create(:membership, payment_type_id: 'payment_type_2')}

    it "includes membreship of all payment type" do
      expect(cs.results).to include my_mem.contact
      expect(cs.results).to include other_mem.contact
    end
  end

  context "with status: due" do
    let(:cs_attributes){{membership_status: "due"}}
    let(:cs){ContactSearch.new(cs_attributes)}

    describe "#results" do
      let!(:yes){FactoryBot.create(:membership,
                                    begins_on: 6.months.ago.beginning_of_month,
                                    ends_on: Date.today.end_of_month)}
      let!(:no_active){FactoryBot.create(:membership,
                                   begins_on: 5.months.ago.beginning_of_month,
                                   ends_on: 1.month.from_now.end_of_month)}
      let!(:no_overdue){FactoryBot.create(:membership,
                                   begins_on: 7.months.ago.beginning_of_month,
                                   ends_on: 1.month.ago.end_of_month)}
      let!(:no_closed){FactoryBot.create(:membership,
                                    begins_on: 6.months.ago.beginning_of_month,
                                    ends_on: Date.today.end_of_month,
                                    closed_on: 1.month.ago.end_of_month)}
      it "includes membership due this month" do
        expect(cs.results).to include yes.contact
      end
      it "wont include membership finishing next month" do
        expect(cs.results).not_to include no_active.contact
      end
      it "wont include membership finished last month" do
        expect(cs.results).not_to include no_overdue.contact
      end
      it "wont include membership ending this month but closed on last month" do
        expect(cs.results).not_to include no_closed.contact
      end
    end
  end

  context "with name" do
    let(:cs_attributes){{name: "Bart"}}
    let(:cs){ContactSearch.new(cs_attributes)}

    describe "#results" do
      let!(:bart){FactoryBot.create(:contact, :name => "Bartholomew Simpson")}
      let!(:homer){FactoryBot.create(:contact, :name => "Homer Simpson")}
      it "includes bart" do
        expect(cs.results).to include bart
      end
      it "wont include homer" do
        expect(cs.results).not_to include homer
      end
    end
  end

  context "with teacher" do
    let(:cs_attributes){{teacher: "luis.perichon"}}
    let(:cs){ContactSearch.new(cs_attributes)}

    describe "#results" do
      let!(:bart){FactoryBot.create(:contact, :padma_teacher => "luis.perichon")}
      let!(:homer){FactoryBot.create(:contact, :padma_teacher => "natalia.sanmartin")}
      it "includes bart's membership" do
        expect(cs.results).to include bart
      end
      it "wont include homer's membership" do
        expect(cs.results).not_to include homer
      end
    end
  end

  context "with status: student" do
    let(:cs_attributes){{status: "student"}}
    let(:cs){ContactSearch.new(cs_attributes)}

    describe "#results" do
      let!(:student){FactoryBot.create(:contact, :padma_status => "student")}
      let!(:another_student){FactoryBot.create(:contact, :padma_status => nil)}
      let!(:yet_another_student){FactoryBot.create(:contact, :padma_status => "student")}
      let!(:former_student){FactoryBot.create(:contact, :padma_status => "former_student")}
      let!(:another_former_student){FactoryBot.create(:contact, :padma_status => "former_student")}
      let!(:yes){FactoryBot.create(:membership,
                                    contact: student)}
      let!(:yes_local){FactoryBot.create(:membership,
                                    contact: another_student)}
      let!(:yes_former){FactoryBot.create(:membership,
                                    contact: former_student)}
      let!(:no){FactoryBot.create(:membership,
                                    closed_on: 1.month.ago,
                                    contact: another_former_student)}
      it "includes a padma student with membership" do
        expect(cs.results).to include student
      end
      it "includes a local contact with membership" do
        expect(cs.results).to include another_student
      end
      it "includes a padma student without membership" do
        expect(cs.results).to include yet_another_student
      end
      it "wont include a former student with membership" do
        expect(cs.results).not_to include former_student
      end
      it "wont include a former_student with closed membership" do
        expect(cs.results).not_to include another_former_student
      end
    end
  end
end
