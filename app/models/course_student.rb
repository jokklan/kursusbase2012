# == Schema Information
#
# Table name: course_students
#
#  id            :integer          not null, primary key
#  student_id    :integer
#  course_id     :integer
#  semester      :string(255)
#  passed        :boolean
#  semester_span :integer
#

class CourseStudent < ActiveRecord::Base
  belongs_to :course
  belongs_to :student

	# NEED FIELD TO SEE IF COURSE HAS BEEN PASSED
end
