Feature: Accessing IO Pro

  So that I can do stuff in IO Pro
  As any IO Pro user
  I want to be able to access IO Pro
  
  Scenario: Log in
    Given I am logged in to velocity admin
    When I go to the Management section of admin
    And I click on the IO Pro tab
    And I click on the Administration button
    And I switch to the IO Pro tab
    Then I should see "Enter Spotlight Manager"
    Then I should see "Enter Terminology Manager"
    Then I should see "Users"
    Then I should see "Environments"
