Feature: Display SOW remaining hours for logged in user

  Based on the user logged in
  Projects for each account should be displayed
  Along with the hours

Scenario: View SOW tasks for a project manager
  Given I login as agray with password blah
  Then I validate the section "SOW Hours"
  Then I validate the "SOW Hours" accounts:
    | account       | project                       | hours |
    | IADB          | Phase 2 - Zahori Enhancements | -1.5  |
    | IADB          | RM-OM MDX Development         | 473.2 |
    | T. Rowe Price | FIS Phase 1                   | 23.3  |
    | T. Rowe Price | FIS Phase 2                   | 110.6 |


Scenario: View SOW tasks for an account manager
  Given I login as user with password blah
  Then I validate the section "SOW Hours"
  Then I validate the "SOW Hours" accounts:
    | account       | project                       | hours |


Scenario: View SOW tasks for Super User
  Given I login as super_user with password blah
  Then I validate the section "SOW Hours"

