class CourseRecommendation < ActiveRecord::Base
  belongs_to :student
  belongs_to :course

	validates_uniqueness_of :course_id, :scope => :student_id
end
