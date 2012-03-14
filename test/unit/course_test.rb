# == Schema Information
#
# Table name: courses
#
#  id              :integer         not null, primary key
#  course_number   :integer
#  language        :string(255)
#  ects_points     :float
#  open_education  :boolean
#  schedule        :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  institute_id    :integer
#  former_course   :string(255)
#  exam_schedule   :string(255)
#  exam_form       :text
#  exam_duration   :string(255)
#  exam_aid        :string(255)
#  evaluation_form :string(255)
#  homepage        :string(255)
#

require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
