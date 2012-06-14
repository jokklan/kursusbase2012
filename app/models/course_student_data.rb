# == Schema Information
#
# Table name: course_student_data
#
#  id              :integer          not null, primary key
#  course_id       :integer
#  student_data_id :integer
#  semester        :string(255)
#

class CourseStudentData < ActiveRecord::Base
  belongs_to :course
  belongs_to :student_data
end
