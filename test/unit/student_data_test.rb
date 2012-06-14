# == Schema Information
#
# Table name: student_data
#
#  id                :integer          not null, primary key
#  student_id        :string(255)
#  field_of_study_id :integer
#  start_date        :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'test_helper'

class StudentDataTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
