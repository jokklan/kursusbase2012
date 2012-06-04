# == Schema Information
#
# Table name: field_course_types
#
#  id                :integer         not null, primary key
#  field_of_study_id :integer
#  course_type_id    :integer
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#

class FieldCourseType < ActiveRecord::Base
  belongs_to :field_of_study
  belongs_to :course_type
	has_and_belongs_to_many :courses
end
