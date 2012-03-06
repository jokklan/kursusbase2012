# == Schema Information
#
# Table name: course_types
#
#  id               :integer         not null, primary key
#  title            :string(255)
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  course_type_type :integer
#

class CourseType < ActiveRecord::Base
  has_and_belongs_to_many :courses
  translates  :title
end
