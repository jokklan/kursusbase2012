# == Schema Information
#
# Table name: courses
#
#  id                :integer         not null, primary key
#  course_number     :integer
#  title             :string(255)
#  language          :string(255)
#  ects_points       :float
#  open_education    :boolean
#  schedule          :string(255)
#  teaching_form     :string(255)
#  duration          :string(255)
#  participant_limit :string(255)
#  course_objectives :text
#  learn_objectives  :text
#  content           :text
#  litteratur        :string(255)
#  institute         :string(255)
#  registration      :string(255)
#  homepage          :string(255)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  remarks           :string(255)
#  institute_id      :integer
#

class Course < ActiveRecord::Base
  # Relations
  has_and_belongs_to_many :teachers
  has_and_belongs_to_many :keywords
  has_and_belongs_to_many :course_types
  
  has_many :point_blocks, :class_name => "CourseRelation", :foreign_key => "course_id", 
            :conditions => [ "related_course_type = ?", "Blocked" ], :after_add => lambda{|data, record| record.set_related_course_type("Blocked")}
  has_many :blocked_courses, :through => :point_blocks, :source => :related_course
  
  has_many :mandatory_qualifications, :class_name => "CourseRelation", :foreign_key => "course_id", 
            :conditions => [ "related_course_type = ?", "Mandatory" ], :after_add => lambda{|data, record| record.set_related_course_type("Mandatory")}
  has_many :mandatory_courses, :through => :mandatory_qualifications, :source => :related_course
  
  has_many :optional_qualifications, :class_name => "CourseRelation", :foreign_key => "course_id", 
            :conditions => [ "related_course_type = ?", "Optional" ], :after_add => lambda{|data, record| record.set_related_course_type("Optional")}
  has_many :optional_courses, :through => :optional_qualifications, :source => :related_course
  
  belongs_to :institute
  has_one :evaluation
  
  #before_create :set_related_course_type

  # Course attributes
  attr_accessible :course_number,:title, 
                  :language, :ects_points, :open_education, 
                  :schedule, :teaching_form, :duration, :participant_limit,
                  :course_objectives, :learn_objectives, :content,
                  :litteratur, :remarks, :institute_id, :registration, :homepage,
                  :top_comment, :exam_schedule, :exam_form, :exam_duration, :exam_aid, :evaluation_form, :former_course
                  
  def set_related_course_type(course_relation, type)
    course_relation.related_course_type = type
  end

  def course_no
    if self.course_number < 9999
      "0#{self.course_number}"
    else
      self.course_number
    end
  end
end
