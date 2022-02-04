require 'rails_helper'

RSpec.describe RecurrentTransaction, type: :model do

  let(:rt) { FactoryBot.create(:recurrent_transaction) }

  describe "create_monthly_transaction_for" do

  end

  it "creates first transaction on creation" do
    expect { FactoryBot.create(:recurrent_transaction) }.to change { Transaction.count }.by 1
  end
  it "wont duplicate transaction on save" do
    t = nil
    expect { t = FactoryBot.create(:recurrent_transaction) }.to change { Transaction.count }.by 1
    expect { t.save }.not_to change { Transaction.count }
  end

end
