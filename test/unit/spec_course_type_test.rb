# == Schema Information
#
# Table name: spec_course_types
#
#  id                  :integer          not null, primary key
#  course_type_type_id :integer
#  field_of_study_id   :integer
#  flag_model_type_id  :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'test_helper'

class SpecCourseTypeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
