# == Schema Information
#
# Table name: courses
#
#  id               :integer          not null, primary key
#  course_number    :integer
#  language         :string(255)
#  ects_points      :float
#  open_education   :boolean
#  schedule         :string(255)
#  institute_id     :integer
#  homepage         :string(255)
#  exam_schedule    :text
#  exam_duration    :string(255)
#  point_block      :string(255)
#  qualified_prereq :string(255)
#  optional_prereq  :string(255)
#  mandatory_prereq :string(255)
#  active           :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  semester_span    :integer          default(1)
#

require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
