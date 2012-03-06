# == Schema Information
#
# Table name: institutes
#
#  id               :integer         not null, primary key
#  title            :string(255)
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  dtu_institute_id :integer
#

require 'test_helper'

class InstituteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
