# == Schema Information
#
# Table name: course_prerequisites
#
#  id              :integer         not null, primary key
#  course_id       :integer
#  req_course_id   :integer
#  req_course_no   :integer
#  prerequisite    :string(255)
#  req_course_type :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

class CoursePrerequisite < ActiveRecord::Base
  belongs_to :course
  belongs_to :req_course, :class_name => "Course"
end
