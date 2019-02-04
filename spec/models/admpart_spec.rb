require 'spec_helper'

describe Admpart, :type => :model do

  before do
    Rails.cache.clear
  end

  let(:admpart){  FactoryGirl.create(:admpart) }
  let(:b){ admpart.business }

  describe "get_for_ref_date" do
    describe "if already created" do
      let!(:admpart){ FactoryGirl.create(:admpart, ref_date: Date.today) }
      it "returns existing one" do
        expect(Admpart.get_for_ref_date(Date.today)).to eq admpart
      end
    end
    describe "if no admpart for ref_date" do
      it "creates a new admpart copying previous but with new ref_date" do
        expect(Admpart.get_for_ref_date(Date.today)).to be_a Admpart
      end
    end
  end


  describe "total_for_tag" do
    describe "for tag in section income" do
      let(:tag){ FactoryGirl.create(:tag, business_id: b.id, admpart_section: "income") }
      before do
        FactoryGirl.create(:transaction, business_id: b.id, type: "Credit", amount: 10, tag_id: tag.id)
      end

      describe "if force_refresh false" do
        before do
          admpart.force_refresh = false
        end
        it "caches results" do
          pre = admpart.total_for_tag(tag)
          FactoryGirl.create(:transaction, business_id: b.id, type: "Credit", amount: 10, tag_id: tag.id, admpart_tag_id: tag.id)
          expect( admpart.reload.total_for_tag(tag) ).to eq pre
        end
        describe "calling refresh_cache" do
          it "refreshes cache" do
            pre = admpart.total_for_tag(tag).to_f

            FactoryGirl.create(:transaction, business_id: b.id,
                               type: "Credit", amount: 10,
                               tag_id: tag.id, admpart_tag_id: tag.id,
                               report_at: Date.today)
            expect( admpart.transactions_for_tag(tag).sum(:amount) ).to eq pre+10
            expect( admpart.total_for_tag(tag) ).to eq pre

            FactoryGirl.create(:transaction, business_id: b.id,
                               type: "Credit", amount: 10,
                               tag_id: tag.id, admpart_tag_id: tag.id,
                               report_at: Date.today)

            expect( admpart.total_for_tag(tag) ).to eq pre
            admpart.refresh_cache
            expect( admpart.total_for_tag(tag) ).to eq (pre+20)
          end
        end   
      end
      describe "if force_refresh true" do
        before do
          admpart.force_refresh = true
        end
        it "ignores cache an recalculates" do
          expect( admpart.total_for_tag(tag) ).to eq 10
          FactoryGirl.create(:transaction, business_id: b.id, type: "Credit", amount: 10, tag_id: tag.id)
          expect( admpart.total_for_tag(tag) ).to eq 20
        end
      end
    end
  end


end
