require 'rails_helper'

RSpec.describe TransactionRule, :type => :model do

  let(:contact){ FactoryBot.create(:contact) }
  let(:agent){ FactoryBot.create(:agent) }
  let(:tag){ FactoryBot.create(:tag) }

  describe "matches?" do
    let(:rule){ FactoryBot.create(:transaction_rule, operator: operator, value: value, contact: FactoryBot.create(:contact)) }
    describe "with 'regex' operator" do
      let(:operator){ "regex" }
      let(:value){ ".uck"}
      it "returns true if description matches rule's value" do
        expect(
            rule.matches?(FactoryBot.build(:transaction, description: 'es un duck amarillo'))
        ).to be_truthy
        expect(
            rule.matches?(FactoryBot.build(:transaction, description: 'fuck this shit'))
        ).to be_truthy
      end
    end
    describe "with 'contains' operator" do
      let(:operator){ "contains" }
      let(:value){ ".uck"}
      it "returns true if description matches rule's value" do
        expect(
            rule.matches?(FactoryBot.build(:transaction, description: 'es un duck amarillo'))
        ).to be_falsey
        expect(
            rule.matches?(FactoryBot.build(:transaction, description: 'fuck this shit'))
        ).to be_falsey
        expect(
            rule.matches?(FactoryBot.build(:transaction, description: '.uck this shit'))
        ).to be_truthy
      end
    end
  end

end
