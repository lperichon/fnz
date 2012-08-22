Feature: Edit Business
  As a registered user of the website
  When I have a created business
  I want to edit my business
  so I can change its name

    Scenario: I sign in and edit my business
      Given I am logged in
      And I have created a business
      And I look at the business
      When I edit my business
      Then I should see a business edited message
