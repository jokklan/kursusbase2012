# == Schema Information
#
# Table name: field_of_studies
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class FieldOfStudy < ActiveRecord::Base
  has_many :students
	has_many :spec_course_types
	has_many :courses, :through => :spec_course_types
	
	has_one :main_course_type, :class_name => 'SpecCourseType', :conditions => ["flag_model_type_id = ?", 2]
	has_many :main_courses, :through => :main_course_type, :source => :courses
	
	has_one :project_course_type, :class_name => 'SpecCourseType', :conditions => ["flag_model_type_id = ?", 5]
	has_many :project_courses, :through => :project_course_type, :source => :courses
	
	has_one :basic_course_type, :class_name => 'SpecCourseType', :conditions => ["flag_model_type_id = ?", 1]
	has_many :basic_courses, :through => :basic_course_type, :source => :courses
	
	translates :title
end
