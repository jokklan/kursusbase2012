# encoding: utf-8
namespace :import do
	require 'pp'
	desc "Import student data from csv"
  task :student_data, [:filename] => :environment do |t,args|
		require 'csv'    
		
		studyline_corrector = {
			 "FYS & NAN"	=> 'Fysik og nanoteknologi', 
			 "DES & INN"	=> 'Design og innovation',
			 "MILJOTEK"		=> 'Miljøteknologi',
			 "PRO & KON"	=> 'Produktion og konstruktion',
			 "ELEKTROTEK" => 'Elektroteknologi',
			 "MED & TEK"	=> 'Medicin og teknologi',
			 "SOFTWARE"		=> 'Softwareteknologi',
			 "MAT & TEK"	=> 'Matematik og teknologi',
			 "KEMI & TEK"	=> 'Kemi og teknologi',
			 "BYGGETEK"		=> 'Byggeteknologi',
			 "TEKBIO"			=> 'Teknologibio',
			 "SUN & PRO"	=> 'Teknisk biomedicin',
			 "BIOTEK"			=> 'Bioteknologi',
			 "IT & KOM"		=> 'IT og kommunikationsteknologi',
			 "KOMMUTEK"		=> 'kommunikationsteknologi',
			 "BBYGDES"		=> 'Bygningsdesign'
		}
		
		file = 'db/student_data.csv'
		studylines = []
		CSV.foreach(file) do |row|
			row = row.to_s.split(';')
			id_row = row[0]
			id = id_row[2..id_row.length]
			start = row[1]
			studyline_row = row[4]
			studyline = studyline_row[0..(studyline_row.length - 3)]
			
			datex = %r{(\d{2})\/(\d{2})\/(\d{2})}.match(start.to_s)
			year = 2000+datex[3].to_i
			month = datex[2].to_i
			day = datex[1].to_i
			datetime = DateTime.civil(year, month, day)
			
			fos = FieldOfStudy.find_or_create_by_name(studyline_corrector[studyline]) unless studyline_corrector[studyline].nil?
			
			StudentData.create({
				:student_id => id,
				:field_of_study => fos,
				:start_date => datetime
			}) unless fos.nil?
			puts "id: #{id}, fos: #{fos.id}, start: #{datetime}"
		end
	end
	
	desc "Import student data from csv"
  task :course_data, [:filename] => :environment do |t,args|
		require 'csv'    
		file = 'db/course_data.csv'
		CSV.foreach(file,"r:ISO-8859-1") do |row|
			#puts row
			row = row.to_s.split(';')
			id_row = row[0]
			id = id_row[2..id_row.length]
			course_row = row[1]
			course = course_row[0..(course_row.length - 3)]
			course_number = %r{^\d{5}}.match(course).to_s.to_i
			semester_match = %r{.*((Jun|Jan|E|F).?\d{2})}.match(course)
			course_semester = semester_match[1] unless semester_match.nil?
			
			puts "id: #{id}, course: #{course_number}, semester: #{course_semester}" 
		end
		#lines = IO.readlines('db/student_data.csv', )
		##lines = File.new('db/student_data.csv', "r:ISO-8859-1").readlines
		#lines.each do |line|
	  #  params = {}
	  #  values = line.strip.split(';')
	  #  puts values
	  #end
	end
end