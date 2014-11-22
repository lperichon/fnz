require 'spec_helper'

describe InstallmentSearch do
  describe "persisted?" do
    let(:ms){InstallmentSearch.new}
    it "returns false" do
      expect(ms).not_to be_persisted
    end
  end

  context "with status" do
    let(:status){'overdue'}
    let(:is_att){{status: status}}
    let(:is){InstallmentSearch.new(is_att)}

    let(:my_inst){FactoryGirl.create(:installment, status: status)}
    let(:other_inst){FactoryGirl.create(:installment)}

    it "includes installment in given status" do
      expect(is.results).to include my_inst
    end
    it "excludes installments in other status" do
      expect(is.results).not_to include other_inst
    end
  end

  context "with due_after: 2014-1-1" do
    let(:is_attributes){{due_after: Date.civil(2014,1,1)}}
    let(:is){InstallmentSearch.new(is_attributes)}

    describe "#results" do
      let!(:yes){FactoryGirl.create(:installment,
                                    due_on: Date.civil(2014,2,1))}
      let!(:no){FactoryGirl.create(:installment,
                                   due_on: Date.civil(2013,2,1))}
      it "includes installment due on 2014-2-1" do
        expect(is.results).to include yes
      end
      it "doesnt include installment due on 2013-2-1" do
        expect(is.results).not_to include no
      end
    end
  end

  context "with agent" do
    let(:agent_id){'agent_id'}
    let(:is_att){{agent_id: agent_id}}
    let(:is){InstallmentSearch.new(is_att)}

    let(:my_inst){FactoryGirl.create(:installment, agent_id: agent_id)}
    let(:other_inst){FactoryGirl.create(:installment)}

    it "includes installment of given agent" do
      expect(is.results).to include my_inst
    end
    it "excludes installments of another agent" do
      expect(is.results).not_to include other_inst
    end
  end

  context "with agent_all" do
    let(:agent_id){'all'}
    let(:is_att){{agent_id: agent_id}}
    let(:is){InstallmentSearch.new(is_att)}

    let(:my_inst){FactoryGirl.create(:installment, agent_id: 'agent_1')}
    let(:other_inst){FactoryGirl.create(:installment, agent_id: 'agent_2')}

    it "includes installment of all agents" do
      expect(is.results).to include my_inst
      expect(is.results).to include other_inst
    end
  end  
end
