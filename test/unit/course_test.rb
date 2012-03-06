# == Schema Information
#
# Table name: courses
#
#  id                :integer         not null, primary key
#  course_number     :integer
#  title             :string(255)
#  language          :string(255)
#  ects_points       :float
#  open_education    :boolean
#  schedule          :text
#  teaching_form     :text
#  duration          :string(255)
#  participant_limit :string(255)
#  course_objectives :text
#  learn_objectives  :text
#  content           :text
#  litteratur        :text
#  institute         :string(255)
#  registration      :string(255)
#  homepage          :string(255)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  remarks           :text
#  institute_id      :integer
#  top_comment       :text
#  former_course     :string(255)
#  exam_schedule     :text
#  exam_form         :text
#  exam_duration     :string(255)
#  exam_aid          :string(255)
#  evaluation_form   :string(255)
#

require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
