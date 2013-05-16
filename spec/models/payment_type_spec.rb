require 'spec_helper'

describe PaymentType do
  describe "belongs to a business" do
    it { should belong_to :business }
    it { should validate_presence_of :business }
  end

  describe "has a name" do
    it { should have_db_column :name }
    it { should validate_presence_of :name}
  end

  describe "has a description" do
    it { should have_db_column :description }
  end
end
