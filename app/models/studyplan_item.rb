# == Schema Information
#
# Table name: studyplan_items
#
#  id           :integer          not null, primary key
#  studyplan_id :integer
#  course_id    :integer
#  student_id   :integer
#  semester     :integer
#

class StudyplanItem < ActiveRecord::Base
  belongs_to :student
  belongs_to :course

	validates :course_id, :uniqueness => { :scope => :student_id }
end
