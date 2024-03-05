Feature: Display Jira tasks for logged in user

  Based on the user logged in
  JIRA tasks should be displayed

Scenario: View Jira tasks
  Given I login as a user with projects defined
  Then I view select Jira tasks
  Given I login as a user with no projects defined
  Then I view all the Jira tasks