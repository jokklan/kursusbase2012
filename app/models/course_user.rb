# == Schema Information
#
# Table name: course_users
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  course_id  :integer
#  semester   :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class CourseUser < ActiveRecord::Base
  belongs_to :course
  belongs_to :user
end
