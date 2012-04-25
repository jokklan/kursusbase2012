# == Schema Information
#
# Table name: courses
#
#  id              :integer         not null, primary key
#  course_number   :integer
#  language        :string(255)
#  ects_points     :float
#  open_education  :boolean
#  schedule        :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  institute_id    :integer
#  former_course   :string(255)
#  exam_schedule   :string(255)
#  exam_form       :text
#  exam_duration   :string(255)
#  exam_aid        :string(255)
#  evaluation_form :string(255)
#  homepage        :string(255)
#

class Course < ActiveRecord::Base
  serialize :learn_objectives, Array
  # Relations
  has_and_belongs_to_many :teachers
  has_and_belongs_to_many :keywords
  has_and_belongs_to_many :main_course_types, :class_name => "CourseType", :conditions => [ "course_type_type = ?", "Main" ]
  has_and_belongs_to_many :spec_course_types, :class_name => "CourseType", :conditions => [ "course_type_type = ?", "Spec" ]
  
  has_many :point_blocks, :class_name => "CourseRelation", :foreign_key => "course_id", 
            :conditions => [ "related_course_type = ?", "Blocked" ], :after_add => lambda{|data, record| record.set_related_course_type("Blocked")}
  has_many :blocked_courses, :through => :point_blocks, :source => :related_course
  
  has_many :mandatory_qualifications, :class_name => "CourseRelation", :foreign_key => "course_id", 
            :conditions => [ "related_course_type = ?", "Mandatory" ], :after_add => lambda{|data, record| record.set_related_course_type("Mandatory")}
  has_many :mandatory_courses, :through => :mandatory_qualifications, :source => :related_course
  
  has_many :optional_qualifications, :class_name => "CourseRelation", :foreign_key => "course_id", 
            :conditions => [ "related_course_type = ?", "Qualification" ], :after_add => lambda{|data, record| record.set_related_course_type("Qualification")}
  has_many :qualification_courses, :through => :optional_qualifications, :source => :related_course
  
  has_many :advisable_qualifications, :class_name => "CourseRelation", :foreign_key => "course_id", 
            :conditions => [ "related_course_type = ?", "Optional" ], :after_add => lambda{|data, record| record.set_related_course_type("Optional")}
  has_many :optional_courses, :through => :advisable_qualifications, :source => :related_course
  
  has_many :course_users
  has_many :users, :through => :course_users
	has_many :course_student_datas
	has_many :student_datas, :through => :course_student_datas
  
  belongs_to :institute

	has_and_belongs_to_many :schedules
	has_and_belongs_to_many :student_datas
  
  # Course attributes
  attr_accessible :course_number,:title, 
                  :language, :ects_points, :open_education, :active,
                  :schedule, :teaching_form, :duration, :participant_limit,
                  :course_objectives, :learn_objectives, :content,
                  :litteratur, :remarks, :institute_id, :registration, :homepage, :top_comment, :former_course,
                  :exam_schedule, :exam_form, :exam_duration, :exam_aid, :evaluation_form,
									:point_block, :qualified_prereq, :optional_prereq, :mandatory_prereq

  # Translations
  #  translates   :title, 
  #               :teaching_form, :duration, :participant_limit,  
  #               :course_objectives, :learn_objectives, :content,
  #               :litteratur, :remarks, :registration, :homepage, 
  #               :top_comment
  #               
  translates   :title, 
               :teaching_form, :duration, :participant_limit,  
               :course_objectives, :learn_objectives, :content,
               :litteratur, :remarks, :registration, :top_comment, :former_course,
               :exam_form, :exam_aid, :evaluation_form
  
   # Instance methods  
  def set_related_course_type(course_relation, type)
    course_relation.related_course_type = type
  end



	def serialize_objectives
		if !self.learn_objectives.nil? && !self.learn_objectives.empty?
			self.learn_objectives = self.learn_objectives.split(">")
		end
	end

  def course_no
    if self.course_number < 9999
      "0#{self.course_number}"
    else
      self.course_number
    end
  end
  
  def season()
    if schedule[0] = "F"
      I18n.translate('courses.spring')
    elsif schedule[0] = "E"
      I18n.translate('courses.autumn')
    end
  end

	def recommended_courses
		rec_courses = []
		CourseRelation.where(['related_course_id = ? AND related_course_type = ?', self.id, "Mandatory"]).sort.each do |cr|
			rec_courses << Course.find(cr.course_id)
		end
		CourseRelation.where(['related_course_id = ? AND related_course_type = ?', self.id, "Qualification"]).sort.each do |cr|
			course = Course.find(cr.course_id)
			rec_courses << course unless rec_courses.include? course
		end
		CourseRelation.where(['related_course_id = ? AND related_course_type = ?', self.id, "Optional"]).sort.each do |cr|
			course = Course.find(cr.course_id)
			rec_courses << course unless rec_courses.include? course
		end
		return rec_courses
	end
	
	def similar_courses
		n_values = 10 # how many results?
		rec_array = {}
		CourseStudentData.where('course_id = ?',self.id).each do |data|
			CourseStudentData.where('student_data_id = ?',data.student_data_id).each do |course_taken|
				c_id = course_taken.course_id
				if rec_array[c_id].nil?
					rec_array[c_id] = 1 
				else
					rec_array[c_id] = rec_array[c_id] + 1
				end
			end
		end
		
		sorted_array = rec_array.sort_by {|k,v| v }.reverse
		index = 0
		result = {}
		sorted_array.each do |key,value|
			break if index > n_values
			if not key == self.id
				result[value] = Course.find(key)
				index = index + 1
			end
		end
		return result
	end
end
