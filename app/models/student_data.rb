# == Schema Information
#
# Table name: student_data
#
#  id                :integer          not null, primary key
#  student_id        :string(255)
#  field_of_study_id :integer
#  start_date        :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class StudentData < ActiveRecord::Base
  belongs_to :field_of_study
	has_many :course_student_datas
	has_many :courses, :through => :course_student_datas
	
	validates :student_id, :uniqueness => true
end
