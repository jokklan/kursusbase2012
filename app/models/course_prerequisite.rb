class CoursePrerequisite < ActiveRecord::Base
  belongs_to :course
  belongs_to :req_course, :class_name => "Course", :polymorphic => true
end
