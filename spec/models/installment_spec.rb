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


  describe "#due" do
    before do
      @installment = FactoryGirl.create(:installment, :membership => @membership, :agent => @agent, :due_on => Date.today.end_of_month)
    end
    it "should be due" do
      Installment.due.should include(@installment)
    end
  end

  describe "#overdue" do
    before do
      @installment = FactoryGirl.create(:installment, :membership => @membership, :agent => @agent, :due_on => 1.month.ago)
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

    describe "when there is one comple@ted transaction" do
      before do
        source_account = FactoryGirl.create(:account, :business => @membership.business)
        @transaction = FactoryGirl.create(:transaction, :type => "Credit", :business => @membership.business, :source => source_account, :creator => @membership.business.owner, :transaction_at => @installment.due_on.beginning_of_day)
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

  describe "#build_from_csv" do
  	describe "with a paid ticket" do
  		before do
  			row = ['50025','175.0','2009-04-01','true','50276','2009-04-25','','excel','2009-04-25','','','1','50002']
  			@business = FactoryGirl.create(:school)
  			@membership = FactoryGirl.create(:membership, :business => @business, :external_id => row[4].to_i)
  			@installment = Installment.build_from_csv(@business, row)
  		end

  		it "should create a valid installment" do
  			@installment.should be_valid
  		end

  		it "should create a payment transaction" do
  			expect {
				@installment.save		       
		      }.to change{Transaction.count}.by(1)
  		end
  	end

  	describe "with an unpaid ticket" do
  		before do
  			row = ['50190','180.0','2009-05-10','false','50360','','','','','','','1','50002']
  			@business = FactoryGirl.create(:school)
  			@membership = FactoryGirl.create(:membership, :business => @business, :external_id => row[4].to_i)
  			@installment = Installment.build_from_csv(@business, row)
  		end

  		it "should create a valid installment" do
  			@installment.should be_valid
  		end

  		it "should not create a payment transaction" do
  			expect {
				@installment.save		       
		    }.to_not change{Transaction.count}
  		end
  	end
  end
end