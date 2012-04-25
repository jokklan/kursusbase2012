# == Schema Information
#
# Table name: course_students
#
#  id        :integer         not null, primary key
#  student_id   :integer
#  course_id :integer
#  semester  :string(255)
#

class CourseStudent < ActiveRecord::Base
  belongs_to :course
  belongs_to :student
end