# == Schema Information
#
# Table name: students
#
#  id             :integer         not null, primary key
#  student_number :string(255)
#  direction_id   :integer
#  start_year     :integer
#  cn_access_key  :string(255)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

class Student < ActiveRecord::Base
  belongs_to :field_of_study
  has_many :course_students
  has_many :courses, :through => :course_students
	has_many :passed_courses, :through => :course_students, :class_name => 'Course', :source => :course, :conditions => ['passed = ?', true]
	has_many :course_recommendations
	has_many :studyplan_items
	has_many :main_courses, :through => :field_of_study, :class_name => 'Course', :source => :main_courses
	has_many :project_courses, :through => :field_of_study, :class_name => 'Course', :source => :project_courses
	has_many :basic_courses, :through => :field_of_study, :class_name => 'Course', :source => :basic_courses
  
  attr_accessor :password
  
  attr_accessible :student_number, :password, :firstname, :lastname, :email, :field_of_study, :user_id
  
  validates :student_number, :presence => true, :uniqueness => true

  after_create :update_courses

	TOTAL_ECTS_GOAL = 180	
	
	def main_points
		sum_ects_points(self.main_courses.select {|c| self.courses.include? c or self.studyplan_courses.include? c })
	end
	
	def main_points_passed
		sum_ects_points(self.main_courses.select {|c| self.passed_courses.include? c  })
	end
	
	def project_points
		self.sum_ects_points(self.project_courses.select {|c| self.courses.include? c or self.studyplan_courses.include? c })
	end
	
	def project_points_passed
		self.sum_ects_points(self.project_courses.select {|c| self.passed_courses.include? c })
	end
	
	def basic_points
		# skal ikke tælle, hvis kursus også er teknologisk linjefag for den givne studerende
		sum_ects_points(self.basic_courses.select {|c| self.courses.include? c or self.studyplan_courses.include? c })
	end
	
	def basic_points_passed
		sum_ects_points(self.basic_courses.select {|c| self.passed_courses.include? c })
	end
	
	def optional_points
		# skal også tælde, hvis der overskrides point i de andre farver
		self.courses.sum("ects_points") + self.sum_ects_points(self.studyplan_courses) - basic_points - project_points - main_points
	end
	
	def optional_points_passed
		self.passed_courses.sum("ects_points") - basic_points_passed - project_points_passed - main_points_passed
	end
	
	def total_points
		self.courses.sum("ects_points")
	end
	
	def total_points_passed
		self.passed_courses.sum("ects_points")
	end
	
	def sum_ects_points(courses)
		sum = 0.0
		courses.each {|c| sum += c.ects_points }
		sum
	end
	
  def fullname
    "#{firstname} #{lastname}"
  end
  
  def authenticate(pass = password)
    require "net/http"
    require "uri"
    
    uri = URI.parse("https://auth.dtu.dk/dtu/mobilapp.jsp")

    http = Net::HTTP.new(uri.host, uri.port)

    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"username" => self.student_number, "password" => pass})
    response = http.request(request)
    
    if response.body =~ /LimitedAccess Password/ && key = /Password=\"([^\"]*)\"/.match(response.body)
      self.cn_access_key = key[1]
      true
    else
      time = /TryAgainIn=\"00:00:([\d\.]+)"/.match(response.body)
      if time[1].to_f < 5
        errors.add(:base, I18n.translate('students.errors.wrong_username_or_password_try_again', :time => time[1].to_i))
      else
        errors.add(:base, I18n.translate('students.errors.wrong_username_or_password'))
      end
      false
    end
  end
  
  def update_image
    raise Exception, 'Student have no user id, and cannot connect to CampusNet' if user_id.blank? && update_info.blank?

    image = CampusNet.api_call(self, "Users/#{user_id}/Picture")["User"]
  end
  
  def update_info
    info = CampusNet.api_call(self, "UserInfo")["User"]
    if info.nil?
      puts "CAMBUS NET API CALL FAILED, OLD COURSES: #{info.to_yaml}"
    else
      self.update_attributes(firstname: info["GivenName"], lastname: info["FamilyName"], user_id: info["UserId"],  email: info["Email"])
    end
  end
  
  def update_old_courses
    call = CampusNet.api_call(self, "Grades")
    cn_courses = call['EducationProgrammes']['EducationProgramme']['ExamResults']['ExamResult']
    
    if cn_courses.nil?
		  puts "CAMBUS NET API CALL FAILED, OLD COURSES: #{call.to_yaml}"
  	else
      cn_courses.each do |cn_course|
        course_number = cn_course['CourseCode']
        course = Course.find_by_course_number(course_number)
        semester_number = semester(cn_course['Year'], cn_course['Period'] == "Winter" ? 1 : 0 )
        passed = (cn_course['EctsGiven'] == 'true')
        course_students.find_or_create_by_course_id(:course_id => course.id, :semester => semester_number, :passed => passed) unless course.nil?
      end
    end
    self.save
  end
  
  def update_current_courses
    call = CampusNet.api_call(self, "Elements")
    cn_courses = call['ElementGroupings']['Grouping'][0]['Element'].select do |c| 
      c['UserElementRelation']['ACL'] == 'User' && c['IsArchived'] == 'false'
    end
    
    puts cn_courses.to_yaml
		
		if cn_courses.blank?
		  puts "CAMBUS NET API CALL FAILED, CURRENT COURSES: "		  
  	else
  		cn_courses.each do |course|
    	  course_number = course['Name'].match('(\d{5})')[0]
    	  course = Course.find_by_course_number(course_number)
    	  course_students.find_or_create_by_course_id(:course_id => course.id, :semester => semester) unless course.nil?
    	end 
  	end
    self.save
  end
  
  def update_courses
    update_old_courses
    update_current_courses
  end
	
	def find_studyplan_items_by_semester(semester)
		self.studyplan_items.where('semester = ?', semester)
	end
	
	def find_studyplan_courses_by_semester(semester)
		if self.find_studyplan_items_by_semester(semester).empty?
			[]
		else
			self.find_studyplan_items_by_semester(semester).map(&:course)
		end
	end
	
	def course_basket
		self.studyplan_items.where('semester IS NULL', nil).map(&:course)
	end
	
	def studyplan_courses
		self.studyplan_items.where('semester IS NOT NULL').map(&:course)
	end
	
	def has_course_on_schedule(schedule, semester)
		self.find_courses_by_semester(semester).each do |c|
			return true if not c.find_schedules_by_semster(semester).empty?
		end
		false
	end
	
	def has_planned(course)
		self.studyplan_items.map(&:course).include? course
	end
	
	def has_participated(course)
		self.courses.include? course
	end
	
	def has_planned_or_participated_in(course)
		self.has_planned(course) or self.has_participated(course)
	end

	def find_courses_by_semester(semester)
		self.find_course_students_by_semester(semester).map(&:course)
	end
	
	def find_course_students_by_semester(semester)
		course_students = self.course_students.where('semester = ?', semester.to_s)
		course_students += self.course_students.where('semester = ?', (semester.to_i + 1).to_s).select { |cs| cs.course.semester_span.to_i > 1 }
		course_students
	end
  
  def current_courses
    self.find_courses_by_semester(self.semester)
  end

	def current_semester
		self.semester
	end
  
  def semester(year = Time.now.year, semester = Time.now.month === 2...7 ? 1 : 0)
    semester = semester > 1 ? 1 : semester
    (year.to_i - start_year) * 2 + semester
  end
  
  def start_year
    short_year = student_number.match('^s(\d{2})')[1].to_i
    if short_year + 2000 <= Time.now.year + 1
      short_year + 2000
    else
      short_year + 1900
    end
  end

	def should_be_recommended(course)
		not self.courses.include?(course) or self.blocked_courses.include?(course)
	end
	
	def blocked_courses
		blocked_courses = []
		self.courses.each do |c|
			c.blocked_courses.each do |pb|
				blocked_courses << pb
			end
		end
		blocked_courses
	end
	
	def find_recommendations
		if self.course_recommendations.empty?
			puts "calculating recommendations for #{self.student_number}"
			system "/usr/bin/rake pearson:sim_coeff STUDENT_NUMBER='#{self.student_number}' --trace 2>&1 >> #{Rails.root}/log/rake.log &"
		else
			puts "course recommendations not empty?"
		end
	end
	
	def clear_recommendations
		self.course_recommendations.each do |cr|
			cr.destroy
		end
	end
  
  class << self
    ## GLOBALIZE MISSING FUNCTION. HOPELY THERE WILL BE A FIX SOON!
    # def find_or_create_by_student_number!(options = {})
    #   find_by_student_number(options[:student_number]) || create!(options)
    # end
    
  end
    
end
