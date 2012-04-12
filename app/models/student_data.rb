class StudentData < ActiveRecord::Base
  belongs_to :field_of_study
	has_and_belongs_to_many :courses
end
