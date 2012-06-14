# == Schema Information
#
# Table name: course_specializations
#
#  id                   :integer          not null, primary key
#  course_id            :integer
#  spec_course_type_id  :integer
#  optional             :boolean          default(FALSE)
#  recommended_semester :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

require 'test_helper'

class CourseSpecializationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
