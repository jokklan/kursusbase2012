class User < ActiveRecord::Base
  belongs_to :field_of_study
  has_many :course_users
  has_many :courses, :through => :course_users
end
