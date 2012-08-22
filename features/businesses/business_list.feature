Feature: List Businesses
  As a registered user of the website
  I want to see my businesses listed
  so I can know all of my businesses

    Scenario: Viewing businesses
      Given I am logged in
      When I have created a business
      And I look at the list of businesses
      Then I should see at least one business
