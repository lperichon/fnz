require 'spec_helper'

describe Installment do
  
  before(:each) do
    @membership = FactoryGirl.create(:membership)
    @agent = FactoryGirl.create(:agent, :business => @membership.business)
    @attr = {
      :membership_id => @membership.id,
      :agent_id => @agent.id,
      :due_on => Date.today.beginning_of_month,
      :value => 3.2
    }
  end
  
  it "should create a new instance given a valid attribute" do
    Installment.create!(@attr)
  end
  

  it "should require a membership" do
    no_membership_installment = Installment.new(@attr.merge(:membership_id => nil))
    no_membership_installment.should_not be_valid
  end

  it "should NOT require an agent" do
    no_agent_installment = Installment.new(@attr.merge(:agent_id => nil))
    no_agent_installment.should be_valid
  end

  it "should require a due date" do
    no_due_installment = Installment.new(@attr.merge(:due_on => nil))
    no_due_installment.should_not be_valid
  end

  it "should require a value" do
    no_value_installment = Installment.new(@attr.merge(:value => nil))
    no_value_installment.should_not be_valid
  end


  describe "#overdue" do
    before do
      @installment = FactoryGirl.create(:installment, :membership => @membership, :agent => @agent)
    end
    it "should be due" do
      Installment.due.should include(@installment)
    end
  end

  describe "#overdue" do
    before do
      @installment = FactoryGirl.create(:installment, :membership => @membership, :agent => @agent, :due_on => 1.week.ago)
    end
    it "should be overdue" do
      Installment.overdue.should include(@installment)
    end
  end

  describe "#balance" do
    before do
      @installment = FactoryGirl.create(:installment, :membership => @membership, :agent => @agent)
    end
    it "should be 0 to begin" do
      @installment.balance.should eq(0)
    end

    describe "when there is one completed transaction" do
      before do
        source_account = FactoryGirl.create(:account, :business => @membership.business)
        @transaction = FactoryGirl.create(:transaction, :type => "Credit", :business => @membership.business, :source => source_account, :creator => @membership.business.owner)
        @installment.transactions << @transaction
        @installment.reload
      end

      it "should calculate the balance" do
        @installment.balance.should eq(@transaction.amount)
      end

      describe "and it is updated" do
        before do
          @transaction.amount = 123
          @transaction.save
          @installment.reload
        end

        it "should recalculate the installment's balance" do
          @installment.balance.should eq(@transaction.amount)
        end
      end
    end
  end
end