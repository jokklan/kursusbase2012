# == Schema Information
#
# Table name: course_type_types
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CourseTypeType < ActiveRecord::Base
	has_many :spec_course_types
	
	translates :title
end
