class StudyplanItem < ActiveRecord::Base
  belongs_to :student
  belongs_to :course
  belongs_to :schedule
end
