class StudyplanItem < ActiveRecord::Base
  belongs_to :student
  belongs_to :course
  belongs_to :schedule

	validates :course_id, :uniqueness => { :scope => :student_id }
end
