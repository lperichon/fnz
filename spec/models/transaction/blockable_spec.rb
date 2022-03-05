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
end
