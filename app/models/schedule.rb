# == Schema Information
#
# Table name: schedules
#
#  id         :integer         not null, primary key
#  block      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class Schedule < ActiveRecord::Base
	validates :block, :presence => true, :uniqueness => true
	has_many :courses
end
