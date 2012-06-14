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

require 'test_helper'

class StudyplanItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
