require 'spec_helper'

describe Tagging do
  let(:tag){ FactoryBot.create(:tag) }
  let(:transaction){ FactoryBot.create(:transaction, business_id: tag.business_id) }

  describe "when created" do
    it "sets transaction admpart_tag_id" do
      expect(transaction.admpart_tag_id).to be_nil
      transaction.tags << tag
      expect(transaction.reload.admpart_tag_id).to eq tag.id
    end
  end
  describe "when destroyed" do
    it "unsets transaction admpart_tag_id" do
      transaction.tags << tag
      expect(transaction.reload.admpart_tag_id).to eq tag.id
      transaction.taggings.last.destroy
      expect(transaction.reload.admpart_tag_id).to be_nil
    end
  end
end
