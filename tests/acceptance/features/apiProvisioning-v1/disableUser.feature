@api @provisioning_api-app-required
Feature: disable user
  As an admin
  I want to be able to disable a user
  So that I can remove access to files and resources for a user, without actually deleting the files and resources

  Background:
    Given using OCS API version "1"

  @smokeTest
  Scenario: admin disables an user
    Given user "user1" has been created with default attributes and skeleton files
    When the administrator disables user "user1" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "user1" should be disabled

  @smokeTest
  Scenario: Subadmin should be able to disable an user in their group
    Given user "subadmin" has been created with default attributes and skeleton files
    And user "user1" has been created with default attributes and skeleton files
    And group "new-group" has been created
    And user "subadmin" has been added to group "new-group"
    And user "user1" has been added to group "new-group"
    And user "subadmin" has been made a subadmin of group "new-group"
    When user "subadmin" disables user "user1" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "user1" should be disabled

  Scenario: Subadmin should not be able to disable an user not in their group
    Given user "subadmin" has been created with default attributes and skeleton files
    And user "user1" has been created with default attributes and skeleton files
    And group "new-group" has been created
    And group "another-group" has been created
    And user "subadmin" has been added to group "new-group"
    And user "user1" has been added to group "another-group"
    And user "subadmin" has been made a subadmin of group "new-group"
    When user "subadmin" disables user "user1" using the provisioning API
    Then the OCS status code should be "997"
    And the HTTP status code should be "401"
    And user "user1" should be enabled

  Scenario: Subadmins should not be able to disable users that have admin permissions in their group
    Given user "another-admin" has been created with default attributes and skeleton files
    And user "subadmin" has been created with default attributes and skeleton files
    And group "new-group" has been created
    And user "another-admin" has been added to group "admin"
    And user "subadmin" has been added to group "new-group"
    And user "another-admin" has been added to group "new-group"
    And user "subadmin" has been made a subadmin of group "new-group"
    When user "subadmin" disables user "another-admin" using the provisioning API
    Then the OCS status code should be "997"
    And the HTTP status code should be "401"
    And user "another-admin" should be enabled

  Scenario: Admin can disable another admin user
    Given user "another-admin" has been created with default attributes and skeleton files
    And user "another-admin" has been added to group "admin"
    When the administrator disables user "another-admin" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "another-admin" should be disabled

  Scenario: Admin can disable subadmins in the same group
    Given user "subadmin" has been created with default attributes and skeleton files
    And group "new-group" has been created
    And user "subadmin" has been added to group "new-group"
    And the administrator has been added to group "new-group"
    And user "subadmin" has been made a subadmin of group "new-group"
    When the administrator disables user "subadmin" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "subadmin" should be disabled

  Scenario: Admin user cannot disable himself
    Given user "another-admin" has been created with default attributes and skeleton files
    And user "another-admin" has been added to group "admin"
    When user "another-admin" disables user "another-admin" using the provisioning API
    Then the OCS status code should be "101"
    And the HTTP status code should be "200"
    And user "another-admin" should be enabled

  Scenario: disable an user with a regular user
    Given user "user1" has been created with default attributes and skeleton files
    And user "user2" has been created with default attributes and skeleton files
    When user "user1" disables user "user2" using the provisioning API
    Then the OCS status code should be "997"
    And the HTTP status code should be "401"
    And user "user2" should be enabled

  Scenario: Subadmin should not be able to disable himself
    Given user "subadmin" has been created with default attributes and skeleton files
    And group "new-group" has been created
    And user "subadmin" has been added to group "new-group"
    And user "subadmin" has been made a subadmin of group "new-group"
    When user "subadmin" disables user "subadmin" using the provisioning API
    Then the OCS status code should be "101"
    And the HTTP status code should be "200"
    And user "subadmin" should be enabled

  @smokeTest
  Scenario: Making a web request with a disabled user
    Given user "user0" has been created with default attributes and skeleton files
    And user "user0" has been disabled
    When user "user0" sends HTTP method "GET" to URL "/index.php/apps/files"
    Then the HTTP status code should be "403"