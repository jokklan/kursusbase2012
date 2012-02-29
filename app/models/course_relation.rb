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

class CourseRelation < ActiveRecord::Base
  belongs_to :course
  belongs_to :related_course, :class_name => "Course"
  
  def set_related_course_type(type)
    self.related_course_type = type
  end
end