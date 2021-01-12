require 'rails_helper'

describe User do
  
  before(:each) do
    @attr = { 
      :name => "Example User",
      :email => "user@example.com"
    }
  end
  
  it "should create a new instance given a valid attribute" do
    User.create!(@attr)
  end
  
  it "should require an email address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    expect(no_email_user).not_to be_valid
  end
  
  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      expect(valid_email_user).to be_valid
    end
  end
  
  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      expect(invalid_email_user).not_to be_valid
    end
  end
  
  it "should reject duplicate email addresses" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    expect(user_with_duplicate_email).not_to be_valid
  end
  
  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    expect(user_with_duplicate_email).not_to be_valid
  end

  describe "businesses" do
    before(:each) do
      @user = User.create!(@attr)
      @user.businesses.create(:name => "Test Business")
    end

    it "should have businesses" do
      expect(@user).to respond_to(:businesses)
    end

    it "should return a list of businesses" do
      expect(@user.businesses).not_to be_empty
    end
  end

  describe "current_user" do
    before(:each) do
      @user = User.create!(@attr)
      User.current_user = @user
    end

    it "should return the current_user" do
      expect(User.current_user).to eq(@user)
    end
  end

  describe "#time_zone" do

    before(:each) do
      @user = FactoryBot.create(:user, @attr)
      @user.businesses << FactoryBot.create(:business, padma_id: 1)
    end

    it "should have a time_zone" do
      expect(@user).to respond_to(:time_zone)
    end

    it "should have UTC as default" do
      expect(@user.time_zone).to eq("UTC")
    end
  end

end
