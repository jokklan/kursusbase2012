class CourseTypeType < ActiveRecord::Base
	has_many :spec_course_types
	
	translates :title
end
