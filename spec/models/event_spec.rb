require 'spec_helper'

describe Event do
  it { should have_many :inscriptions }

  # describe "#create with derose_events_id" do
  # 	before do
  # 		@user = FactoryBot.create(:user)
  # 		@event = Event.create(derose_events_id: "test", owner_id: @user.id, name: "Test")
  # 	end

  # 	it "should be shared to padma users after create" do
  # 		@school.should have(3).users
  # 	end
  # end

  describe "#create" do
	before do
  		@user = FactoryBot.create(:user)
  		@event = Event.create(owner_id: @user.id, name: "Test")
  	end

  	it "should create a default account" do
  		@event.should have(1).account
  	end  
  end
end