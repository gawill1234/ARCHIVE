Feature: Log in to the application

  So that I can see individual account information
  I need to log in to the application

Scenario: Log in as Anne Gray
  Given I login as agray with password blah
  Then I validate the landing page sections

Scenario: Log in as Super_user
  Given I login as super_user with password blah
  Then I validate the landing page sections
