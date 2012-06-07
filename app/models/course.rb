# encoding: utf-8

# == Schema Information
#
# Table name: courses
#
#  id               :integer         not null, primary key
#  course_number    :integer
#  language         :string(255)
#  ects_points      :float
#  open_education   :boolean
#  schedule         :text
#  institute_id     :integer
#  homepage         :string(255)
#  exam_schedule    :text
#  exam_duration    :string(255)
#  point_block      :string(255)
#  qualified_prereq :string(255)
#  optional_prereq  :string(255)
#  mandatory_prereq :string(255)
#  active           :boolean
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#

class Course < ActiveRecord::Base
  serialize :learn_objectives, Array
  include PgSearch
  
  pg_search_scope :association_search, lambda{ |locale, query, models|
    {
      query: query,
      using: {
        tsearch: {
          prefix: true,
          dictionary: locale == :da ? "danish" : "english"
        }
      },
      associated_against: models
    }
  }
  # 
  # pg_search_scope :number_search, against: :course_number, using: { tsearch: {dictionary: "simple"} }
  #  
  # pg_search_scope :regular_search, lambda{ |locale, query|
  #   {
  #     query: query,
  #     using: {
  #       tsearch: {
  #         dictionary: locale == :da ? "danish" : "english"
  #       }
  #    },
  #     associated_against: {
  #       # translations: {
  #       #   :title => 'A', :course_objectives => 'D', :learn_objectives => 'D', :content => 'D'
  #       # }
  #       translations: [:title, :course_objectives, :learn_objectives, :content]
  #     }
  #   }
  # }
    
  # Relations
  has_and_belongs_to_many :teachers
  has_and_belongs_to_many :keywords
	has_and_belongs_to_many :main_course_types
	has_many :main_course_types_translations, :class_name => "MainCourseType::Translation", :through => :main_course_types, :source => :translations
	
  
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
  
  has_many :course_students
  has_many :students, :through => :course_students
	has_many :course_student_datas
	has_many :student_datas, :through => :course_student_datas
	has_many :course_specializations
	has_many :spec_course_types, :through => :course_specializations
	has_many :field_of_study, :through => :spec_course_types
	has_many :field_of_study_translations, :class_name => "FieldOfStudy::Translation", :through => :field_of_study, :source => :translations
	
	has_many :flag_model_type, :through => :spec_course_types
  # has_many :flag_model_type_translations, :class_name => "FlagModelType::Translation", :through => :flag_model_type, :source => :translations
  
  belongs_to :institute
  has_many :institute_translations, :class_name => "Institute::Translation", :through => :institute, :source => :translations

	has_and_belongs_to_many :schedules
	has_and_belongs_to_many :student_datas
	has_and_belongs_to_many :course_recommendations
  
  # Course attributes
  attr_accessible :course_number,:title, 
                  :language, :ects_points, :open_education, :active,
                  :schedule, :teaching_form, :duration, :participant_limit,
                  :course_objectives, :learn_objectives, :content, :schedule_note,
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
               :course_objectives, :learn_objectives, :content, :schedule_note,
               :litteratur, :remarks, :registration, :top_comment, :former_course,
               :exam_form, :exam_aid, :evaluation_form
               
  # Scopes
  scope :active, where(:active => true)

	def is_basic_course(student)
		student.basic_courses.include? self
	end
	
	def is_main_course(student)
		student.main_courses.include? self
	end
	
	def is_project_course(student)
		student.project_courses.include? self
	end
	
	def is_optional_course(student)
		not self.is_basic_course(student) and not self.is_project_course(student) and not self.is_main_course(student)
	end
               
  def self.is_numeric?(obj) 
    obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end

	def schedule_by_semester(semester)
		return self.schedules.first if schedule.count <= 1
	end
  
  # Class methods
  def self.search(query, locale = I18n.locale)
    if is_numeric? query
      puts "NUMERIC"
      Course.number_search(query.to_i)
    else
      pg_search(query, :courses)
    end
  end
  
  MODEL_ASSOCIATION = {
    institutes: :institute_translations, 
    main_course_types: :main_course_types_translations, 
    field_of_study: :field_of_study_translations,
    flag_model_type: :flag_model_type,
    teachers: :teachers,
    courses: :translations
  }
  
  MODEL_ATTRIBUTE = {
    institutes: :title, 
    teachers: :name, 
    field_of_study: :title,
    flag_model_type: :title,
    main_course_types: :title,
    courses: [:title, :course_objectives, :learn_objectives, :content]
  }
  
  
  def self.pg_search(query, *models)
    model_hash = {} 
    models.each do |m|
      array = "#{MODEL_ATTRIBUTE[m]}".gsub(/[\[\]:\s]/,"").split(",").map{|v| v.to_sym}
      hash = { "#{MODEL_ASSOCIATION[m]}".to_sym => array }
      puts hash.inspect
      model_hash.merge!(hash)
    end

    association_search(I18n.locale, query, model_hash)
  end
  
  def self.search_params(param_string)
    search_string = param_string.dup
    result_query = Course.active.uniq
    
    result_query = if search_string =~ /((?:point|ects)[_-]?((?:gt|lt|eq)e?)?:([\d\,\.]*))/i
      operator = $2
      match = $3
      search_string.gsub!($1, "")
      
      if operator =~ /gte/
        result_query.where{ects_points >= match.gsub(",",".")}
      elsif operator =~ /gt/
        result_query.where{ects_points > match.gsub(",",".")}
      elsif operator =~ /lte/
        result_query.where{ects_points <= match.gsub(",",".")}
      elsif operator =~ /lt/
        result_query.where{ects_points < match.gsub(",",".")}
      else
        result_query.where{ects_points == match.gsub(",",".")}
      end
    else
      result_query
    end
    
    result_query = if search_string =~ /((?:institute?:)([\w-]*))/i
      match = $2
      search_string.gsub!($1, "")
      result_query.pg_search(match.gsub("-"," "), :institutes)
    else
      result_query
    end
    
    result_query = if search_string =~ /((?:coursetype:|kursustype:|type:)([\w-]*))/i
      match = $2
      search_string.gsub!($1, "")
      result_query.pg_search(match.gsub("-"," "), :main_course_types, :flag_model_type, :field_of_study)
    else
      result_query
    end
    
    result_query = if search_string =~ /((?:teacher:|lærer:)([\w-]*))/i
      match = $2
      search_string.gsub!($1, "")
      result_query.pg_search(match.gsub("-"," "), :teachers)
    else
      result_query
    end
    
    result_query = if search_string =~ /((?:language:|sprog:)(english|engelsk|en|danish|dansk|da))/i
      match = $1
      search_string.gsub!(match, "")
      
      if match =~ /english|engelsk|en/
        result_query.where(:language => "English")
      elsif match =~ /danish|dansk|da/
        result_query.where(:language => "Danish")
      else
        result_query
      end
    else
      result_query
    end
    
    result_query = if search_string =~ /((schedule:|skema:)?(E|F)([0-9])(A|B)?|efterår|forår|spring|autumn|fall|january|januar|june|juni)/i
      match = $1
      search_string.gsub!(match, "")
      
      if match =~ /((E|F)([0-9])(A|B)?)/i
        result_query.joins{schedules}.where{schedules.block =~ "#{$1}%"}
      elsif match =~ /(forår|spring)(\d{4})?/
        result_query.joins{schedules}.where{schedules.block =~ "F#{$2}%"}
      elsif match =~ /efterår|fall|autumn/
        result_query.joins{schedules}.where{schedules.block =~ "E%"}
      elsif match =~ /januar|january/
        result_query.joins{schedules}.where{schedules.block == "Januar"}
      elsif match =~ /june|juni/
        result_query.joins{schedules}.where{schedules.block == "Juni"}
      else
        result_query
      end
    else
      result_query
    end
    
    puts (search_string.blank? ? "SQL FOR BLANK: "+result_query.to_sql : "SQL FOR '#{search_string}': "+result_query.search(search_string).to_sql)
    search_string.blank? ? result_query : result_query.pg_search(search_string, :courses)
  end
  
  # Instance methods 
  
  def to_param
    course_number
  end 
  
  def set_related_course_type(course_relation, type)
    course_relation.related_course_type = type
  end

	def serialize_objectives
		if !self.learn_objectives.blank?
			self.learn_objectives = self.learn_objectives.split(">")
		end
	end
	
	def course_number
	  course_no
  end

  def course_no
    if read_attribute(:course_number) < 9999
      "0#{read_attribute(:course_number)}"
    else
      read_attribute(:course_number)
    end
  end

	def prereq_for
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
