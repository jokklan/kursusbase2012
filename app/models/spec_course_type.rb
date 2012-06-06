class SpecCourseType < ActiveRecord::Base
  belongs_to :field_of_study
	belongs_to :course_type_type
	belongs_to :flag_model_type
	has_many :course_specializations
	has_many :courses, :through => :course_specializations
	
	validates :field_of_study, :presence => true
	validates :course_type_type, :presence => true
end
