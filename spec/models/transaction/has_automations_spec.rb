require 'rails_helper'


describe Transaction do

  before(:each) do
    class Debit < Transaction

    end
    @account = FactoryBot.create(:account)
    @attr = {
      :description => "Example Transaction",
      :business_id => @account.business.id,
      :source_id => @account.id,
      :amount => 3.5,
      :transaction_at => 2.days.ago
    }

    User.current_user = @account.business.owner
  end

  let(:contact) { create(:contact)}
  let(:transaction) { build(:transaction, description: "cuota #{contact.name}")}
  it "gets contact from description" do
    transaction.save
    expect(transaction.reload.contact).to eq contact
  end

  describe "transaction rules" do
    let!(:rule){ FactoryBot.create(:transaction_rule, operator: "contains", value: "hola", contact: FactoryBot.create(:contact))}
    it "are applied con create, not update" do
      expect(rule).to be_valid
      t = FactoryBot.build(:transaction, description: "hola como te va", business: rule.business, contact_id: nil)
      t.save
      expect(t.reload.contact_id).not_to be_nil
      expect(t.reload.contact_id).to eq rule.contact_id
      t.contact_id = nil
      t.save
      expect(t.reload.contact_id).to be_nil
    end
  end


end
