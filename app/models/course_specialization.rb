# == Schema Information
#
# Table name: course_specializations
#
#  id                   :integer          not null, primary key
#  course_id            :integer
#  spec_course_type_id  :integer
#  optional             :boolean          default(FALSE)
#  recommended_semester :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class CourseSpecialization < ActiveRecord::Base
  belongs_to :spec_course_type
	belongs_to :course
end
