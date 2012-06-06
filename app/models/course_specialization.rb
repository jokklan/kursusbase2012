class CourseSpecialization < ActiveRecord::Base
  belongs_to :spec_course_type
	belongs_to :course
end
