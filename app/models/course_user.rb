# == Schema Information
#
# Table name: course_relations
#
#  id                  :integer         not null, primary key
#  course_id           :integer
#  related_course_id   :integer
#  req_course_no       :integer
#  prerequisite        :string(255)
#  related_course_type :string(255)
#  created_at          :datetime        not null
#  updated_at          :datetime        not null
#

class CourseUser < ActiveRecord::Base
  belongs_to :course
  belongs_to :user
end
