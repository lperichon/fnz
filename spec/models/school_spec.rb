require 'spec_helper'

describe School do
  describe "has payment types" do
    it { should have_many :sales }
  end

  describe "has memberships" do
    it { should have_many :memberships }
  end

  describe "#create with padma_id" do
  	before do
  		@user = FactoryBot.create(:user)
  		@school = School.create(padma_id: "test", owner_id: @user.id, name: "Test")
  	end

  	it "should be shared to padma users after create" do
  		@school.should have(3).users
  	end

  	it "should create agents for the padma users" do
  		@school.should have(3).agents
  	end
  end

  describe "#create" do
	before do
  		@user = FactoryBot.create(:user)
  		@school = School.create(owner_id: @user.id, name: "Test")
  	end

  	it "should create a default account" do
  		@school.should have(1).account
  	end  
  end
end