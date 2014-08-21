require 'spec_helper'

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
    no_email_user.should_not be_valid
  end
  
  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end
  
  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject duplicate email addresses" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  describe "businesses" do
    before(:each) do
      @user = User.create!(@attr)
      @user.businesses.create(:name => "Test Business")
    end

    it "should have businesses" do
      @user.should respond_to(:businesses)
    end

    it "should return a list of businesses" do
      @user.businesses.should_not be_empty
    end
  end

  describe "current_user" do
    before(:each) do
      @user = User.create!(@attr)
      User.current_user = @user
    end

    it "should return the current_user" do
      User.current_user.should eq(@user)
    end
  end

  describe "#time_zone" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have a time_zone" do
      @user.should respond_to(:time_zone)
    end

    it "should have UTC as default" do
      @user.time_zone.should eq("UTC")
    end
  end

end