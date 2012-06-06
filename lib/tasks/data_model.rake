# encoding: utf-8
namespace :import do
	require 'pp'
	desc "Import student data from csv"
  task :student_data, [:filename] => :environment do |t,args|
		require 'csv'    
		
		studyline_corrector = {
			 "FYS & NAN"	=> 'Fysik og Nanoteknologi', 
			 "DES & INN"	=> 'Design og Innovation',
			 "MILJOTEK"		=> 'Miljøteknologi',
			 "PRO & KON"	=> 'Produktion og Konstruktion',
			 "ELEKTROTEK" => 'Elektroteknologi',
			 "MED & TEK"	=> 'Medicin og Teknologi',
			 "SOFTWARE"		=> 'Softwareteknologi',
			 "MAT & TEK"	=> 'Matematik og Teknologi',
			 "KEMI & TEK"	=> 'Kemi og Teknologi',
			 "BYGGETEK"		=> 'Byggeteknologi',
			 "TEKBIO"			=> 'Bioteknologi',
			 "SUN & PRO"	=> 'Teknisk Biomedicin',
			 "BIOTEK"			=> 'Bioteknologi',
			 "IT & KOM"		=> 'IT og Kommunikationsteknologi',
			 "KOMMUTEK"		=> 'Kommunikationsteknologi',
			 "BBYGDES"		=> 'Bygningsdesign'
		}
		
		studylines_not_on_dtu = [
			'Kommunikationsteknologi',
			'Teknisk Biomedicin'
		]
		
		file = 'db/student_data.csv'
		studylines = []
		CSV.foreach(file) do |row|
			row = row.to_s.split(';')
			id_row = row[0]
			id = id_row[2..id_row.length]
			start = row[1]
			studyline_row = row[4]
			studyline = studyline_row[0..(studyline_row.length - 3)]
			if not start.nil?
				datex = %r{(\d{2})\/(\d{2})\/(\d{2})}.match(start.to_s)
				year = 2000+datex[3].to_i
				month = datex[2].to_i
				day = datex[1].to_i
				datetime = DateTime.civil(year, month, day)
			end
			fos = FieldOfStudy.find_by_title(studyline_corrector[studyline])
			puts "id: #{id}"
			StudentData.create({
				:student_id => id,
				:field_of_study => fos,
				:start_date => datetime
			}) unless fos.nil? or datetime.nil? or id.nil?
		end
	end
	
	desc "Import course data from csv"
  task :course_data, [:filename] => :environment do |t,args|
		require 'csv'    
		file = 'db/course_data.csv'
		#CSV.foreach(file) do |row|
		CSV.foreach(file, "r:ISO-8859-1") do |row|
			#puts row
			row = row.to_s.split(';')
			id_row = row[0]
			id = id_row[2..id_row.length]
			course_row = row[1]
			course_string = course_row[0..(course_row.length - 3)]
			course_number = %r{^\d{5}}.match(course_string).to_s.to_i
			semester_match = %r{.*((Jun|Jan|E|F).?\d{2})}.match(course_string)
			course_semester = semester_match[1] unless semester_match.nil?
			
			year_regex = %r{(\d{2})}.match(course_semester)
			if not year_regex.nil?
				year = year_regex[1].to_i
				if not year.nil?
					if year <= 13
						year += 2000
					else
						year += 1900
					end
				end
			end

			course	 	= Course.find_by_course_number(course_number)
			student 	= StudentData.find_by_student_id(id)			
			
			if not course.nil? and not student.nil?
				if not year.nil? and year >= 1990 and year <= 2013
					semester_regex = %r{([a-zA-Z])}.match(course_semester)
					
					if not semester_regex.nil?
					
						semester = 0
						if semester_regex[1] == 'Jan'
							semester = -1
						elsif semester_regex[1] == 'E'
							semester = 1
						end
						semester_taken = (year - student.start_date.year) * 2 + semester
						if not course.id.nil?
							student.course_student_datas << CourseStudentData.new(:course_id => course.id, :semester => semester_taken)
						end
					else
						student.course_student_datas << CourseStudentData.new(:course_id => course.id)
					end
				else
					student.course_student_datas << CourseStudentData.new(:course_id => course.id)
				end			
			end
		end
		
		# Deleting all student-data without any courses
		puts "Removing redundant studendata"
		StudentData.all.each do |sd|
			sd.destroy if sd.courses.empty?
		end
	end
end