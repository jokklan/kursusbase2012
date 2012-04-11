class Schedule < ActiveRecord::Base
	validates :block, :presence => true, :uniqueness => true
	has_many :courses
end
