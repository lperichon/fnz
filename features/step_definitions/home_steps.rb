When /^I go home$/ do
  visit '/'
end
Then /^I should be required to sign in$/ do
  page.should have_content "You need to sign in or sign up before continuing."
end