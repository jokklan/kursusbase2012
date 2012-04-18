# == Schema Information
#
# Table name: users
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  direction_id :integer
#  start_year   :integer
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

class User < ActiveRecord::Base
  belongs_to :field_of_study
  has_many :course_users
  has_many :courses, :through => :course_users
end
