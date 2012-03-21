Feature: Recommend a course
  In order to choose a new course
  As a student
  I want to get recommendations

	Scenario: Blocked course should not be recommended
	  Given the following course exists:
		  | title 					| course_number |
		  | Good course 		| 12345					|
			|	Blocked course	|	54321					|
		And the following recommandations exist:
			|				|					|
		When I go to the "Course planner" page
		Then I should see "Good course"
		And I should not see "Blocked course"
		
	Scenario: Course becomes recommended based on my ratings
	  Given the following course exists:
		  | title 					| course_number |
		  | Some course 		| 12345					|
			|	Similar course	|	54321					|
		And the following recommandations exist:
			|				|					|
		When I go to the "Course" page
		And I follow "Some course"
		Then I should see "Like?"
		Given I follow "Like?"
		When I go to "Course planner" page
		Then I should see "Similar course"
		
		