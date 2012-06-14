# == Schema Information
#
# Table name: main_course_types
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MainCourseType < ActiveRecord::Base
	translates :title
end
