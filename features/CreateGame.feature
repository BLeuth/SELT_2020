Feature: Allow CardGame user to create a new game

  Background: I select the Login/Sign up page

    Given the following users have been added to the database:
      | username  | password  |
      | username1 | password1 |
    And I am on the login page
    Then I should be on the login page
    When I have opted to login with username "username1" and password "password1"
    Then my account should be successfully logged in
    And I should be on the games home page

Scenario: Go to create game page
  When I have clicked on the create new game button
  Then I should be on the create new game page

Scenario: Go to lobby page
  When I have clicked on the create new game button
  And I create a game with "1" decks, "1" sinks, with "jokers" and "shuffled", of hand size "0"
  Then I should be on the lobby page

