# == Schema Information
#
# Table name: course_recommendations
#
#  id             :integer         not null, primary key
#  student_id     :integer
#  course_id      :integer
#  priority_value :integer
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

class CourseRecommendation < ActiveRecord::Base
  belongs_to :student
  belongs_to :course

	validates_uniqueness_of :course_id, :scope => :student_id
end
