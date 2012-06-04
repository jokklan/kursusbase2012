# == Schema Information
#
# Table name: field_course_types
#
#  id                :integer         not null, primary key
#  field_of_study_id :integer
#  course_type_id    :integer
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#

require 'test_helper'

class FieldCourseTypeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
