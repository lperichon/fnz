require 'rails_helper'

RSpec.describe MonthTagTotal, type: :model do

  let(:b) { create(:business, currency_code: "ARS") }

  describe "calculate_total_amount" do
    let(:rd) { Date.today }
    let(:tag) { create(:tag, business: b) }
    let(:ars_account) { create(:account, currency: "ARS") }
    let(:usd_account) { create(:account, currency: "USD") }

    describe "if exchange_rate found" do
      before do
        mer = create(:month_exchange_rate,
          business: b,
          from_currency_id: "USD",
          to_currency_id: "ARS",
          conversion_rate: 200,
          ref_date: rd
        )
        expect(mer).to be_persisted
        expect(b.month_exchange_rates.conversion_rate("USD","ARS",rd)).not_to be_nil
      end
      it "uses exchange rate" do
        create(:credit, amount_cents: 100, tag: tag, source: ars_account, report_at: rd)
        create(:credit, amount_cents: 100, tag: tag, source: usd_account, report_at: rd)

        mtt = MonthTagTotal.get_for(tag, rd)
        expect(mtt.calculate_total_amount).to eq 100 + 100*200
      end
    end
    describe "if exchange_rate NOT found" do
      before do
        expect(b.month_exchange_rates.conversion_rate("USD","ARS",rd)).to be_nil
      end
      it "raises error" do
        create(:credit, amount_cents: 100, tag: tag, source: ars_account, report_at: rd)
        expect{ create(:credit, amount_cents: 100, tag: tag, source: usd_account, report_at: rd) }.to raise_error
      end
    end
  end
end
