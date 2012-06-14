# == Schema Information
#
# Table name: teachers
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  location       :string(255)
#  phone          :string(255)
#  email          :string(255)
#  dtu_teacher_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class TeacherTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
