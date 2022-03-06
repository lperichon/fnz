require 'rails_helper'

describe 'Transaction::Blockable' do
  let(:block_since) { Date.civil(2020,1,1) }
  let(:business) { FactoryBot.create(:business, block_transactions_before: block_since) }

  describe "blocked?" do

    it "true before block date" do
      t = FactoryBot.build(:transaction, business: business, report_at: block_since-1.day)
      expect(t).to be_blocked
    end

    it "false after block date" do
      t = FactoryBot.build(:transaction, business: business, report_at: block_since+1.day)
      expect(t).not_to be_blocked
    end

  end

  describe "if not blocked" do
    it "cant add transaction before block" do
      t = FactoryBot.build(:transaction, business: business, report_at: block_since-1.day)
      expect(t).not_to be_valid
    end
    it "cant update transaction reporting it before block" do
      t = FactoryBot.create(:transaction, business: business, report_at: block_since+1.day)
      expect(t).to be_valid

      expect( t.update_attributes(report_at: block_since-1.day) ).to be_falsey

      t.report_at = block_since-1.day
      expect(t).not_to be_valid
    end
  end
  describe "if blocked" do
    let(:t) { t = FactoryBot.build(:transaction, business: business, report_at: block_since - 1.day, state: "pending" ); t.save(validate: false); t }
    it "CAN change state and reconciled_at of a blocked transaction" do
      expect(t.update_attributes(state: "reconciled", reconciled_at: block_since+1.day) ).to be_truthy
    end
    it "canT change non allowed attributes" do
      expect(t.update_attributes(amount_cents: 1000) ).to be_falsey
      expect(t.update_attributes(state: "pending", amount_cents: 1000) ).to be_falsey
    end
  end






end
