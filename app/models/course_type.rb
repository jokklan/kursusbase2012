# == Schema Information
#
# Table name: course_types
#
#  id               :integer         not null, primary key
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  course_type_type :string(255)
#

class CourseType < ActiveRecord::Base
  has_and_belongs_to_many :courses
  translates  :title
  
  attr_accessible :title, :course_type_type 
end
