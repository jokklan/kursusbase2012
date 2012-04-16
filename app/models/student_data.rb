class StudentData < ActiveRecord::Base
  belongs_to :field_of_study
	has_many :course_student_datas
	has_many :courses, :through => :course_student_datas
	
	validates :student_id, :uniqueness => true
end
