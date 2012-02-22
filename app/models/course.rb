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
#

class Course < ActiveRecord::Base
  # Relations
  has_and_belongs_to_many :teachers
  has_and_belongs_to_many :keywords
  has_and_belongs_to_many :course_types
  has_many :course_prerequisites
  # has_many :point_blocks, :through => :course_prerequisites, :foreign_key => :req_course_id
  # has_many :mandatory_qualifications, :through => :course_prerequisites, :as => :req_courses
  # has_many :optional_qualifications, :through => :course_prerequisites, :as => :req_courses
  belongs_to :institute
  has_one :evaluation  

  # Course attributes
  attr_accessible :course_number,:title, 
                  :language, :ects_points, :open_education, 
                  :schedule, :teaching_form, :duration, :participant_limit,
                  :course_objectives, :learn_objectives, :content,
                  :litteratur, :institute, :registration, :homepage
end
