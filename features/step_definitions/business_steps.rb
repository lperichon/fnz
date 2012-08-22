When /^I have created a business$/ do
  @business = @user.businesses.create(:name => "Test Business")
end
When /^I edit my business$/ do
  click_link "Edit"
  fill_in "Name", :with => "newname"
  click_button "Update"
end
Then /^I should see a business edited message$/ do
  page.should have_content "Business was successfully updated."
end
When /^I look at the list of businesses$/ do
  visit '/businesses'
end
Then /^I should see at least one business$/ do
  page.should have_content "Test Business"
end
When /^I look at the business$/ do
  visit "/businesses/#{@business.id}"
end