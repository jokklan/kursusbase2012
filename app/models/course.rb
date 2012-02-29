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
  
  has_many :course_relations
  has_many :blocked_courses, :through => :course_relations, :source => :req_course, :conditions => [ "req_course_type = ?", "PointBlock" ]
  has_many :mandatory_courses, :through => :course_relations, :source => :req_course, :conditions => [ "req_course_type = ?", "Mandatory" ]
  has_many :optional_courses, :through => :course_relations, :source => :req_course, :conditions => [ "req_course_type = ?", "Optional" ]
  
  belongs_to :institute
  has_one :evaluation  

  # Course attributes
  attr_accessible :course_number,:title, 
                  :language, :ects_points, :open_education, 
                  :schedule, :teaching_form, :duration, :participant_limit,
                  :course_objectives, :learn_objectives, :content,
                  :litteratur, :remarks, :institute, :registration, :homepage
end
