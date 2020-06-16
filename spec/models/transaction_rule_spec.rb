require 'spec_helper'

RSpec.describe TransactionRule, :type => :model do

  let(:contact){ FactoryGirl.create(:contact) }
  let(:agent){ FactoryGirl.create(:agent) }
  let(:tag){ FactoryGirl.create(:tag) }

  describe "matches?" do
    let(:rule){ FactoryGirl.create(:transaction_rule, operator: operator, value: value, contact: FactoryGirl.create(:contact)) }
    describe "with 'regex' operator" do
      let(:operator){ "regex" }
      let(:value){ ".uck"}
      it "returns true if description matches rule's value" do
        expect(
            rule.matches?(FactoryGirl.build(:transaction, description: 'es un duck amarillo'))
        ).to be_truthy
        expect(
            rule.matches?(FactoryGirl.build(:transaction, description: 'fuck this shit'))
        ).to be_truthy
      end
    end
    describe "with 'contains' operator" do
      let(:operator){ "contains" }
      let(:value){ ".uck"}
      it "returns true if description matches rule's value" do
        expect(
            rule.matches?(FactoryGirl.build(:transaction, description: 'es un duck amarillo'))
        ).to be_falsey
        expect(
            rule.matches?(FactoryGirl.build(:transaction, description: 'fuck this shit'))
        ).to be_falsey
        expect(
            rule.matches?(FactoryGirl.build(:transaction, description: '.uck this shit'))
        ).to be_truthy
      end
    end
  end

end
