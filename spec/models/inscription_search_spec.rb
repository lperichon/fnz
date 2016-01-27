require 'spec_helper'

describe InscriptionSearch do
  describe "persisted?" do
    let(:ms){InscriptionSearch.new}
    it "returns false" do
      expect(ms).not_to be_persisted
    end
  end
end
