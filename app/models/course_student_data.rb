class CourseStudentData < ActiveRecord::Base
  belongs_to :course
  belongs_to :student_data
end
