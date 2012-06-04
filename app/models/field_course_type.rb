class FieldCourseType < ActiveRecord::Base
  belongs_to :field_of_study
  belongs_to :course_type
	has_and_belongs_to_many :courses
end
