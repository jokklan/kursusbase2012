Feature: Show a course
  In order to learn about a course
  As a student
  I want to have information about that course

	Scenario: Visit a course page
	  Given the following course exists:
		  | title 			| course_number |
		  | Test Course | 12345					|
		When I go to the home page
		And I follow "Test Course"
		Then I should see "Test Course"
		And I should see "12345"