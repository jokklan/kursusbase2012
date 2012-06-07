class Studyplan < ActiveRecord::Base
  belongs_to :student
	has_many :studyplan_items
end
