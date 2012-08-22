Feature: Home page
  As a registered user of the website
  I want to see my businesses listed on the homepage
  so I can know all of my businesses

  Scenario: Logged in user goes home
    Given I am logged in
    When I have created a business
    And I go home
    Then I should see at least one business

  Scenario: visitor goes home
  Scenario: User enters wrong email
    Given I exist as a user
    And I am not logged in
    And I go home
    Then I should be required to sign in