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
		
		#csv_text = File.read('db/student_data.csv')
		#csv = CSV.parse(csv_text)
		#csv.each do |row|
		#	data = row.split(';')
		#	puts row
		#	#puts "ID: #{data[0]}, Started: #{data[1]}, Study line: #{data[4]}"
		#end
		file = 'db/student_data.csv'
		studylines = []
		CSV.foreach(file) do |row|
			row = row.to_s.split(';')
			id_row = row[0]
			id = id_row[2..id_row.length]
			start = row[1]
			studyline_row = row[4]
			studyline = studyline_row[0..(studyline_row.length - 3)]
			studylines << studyline unless studylines.include? studyline
		end
		
		studylines.each do |sl|
			puts studyline_corrector[sl] if not studyline_corrector[sl].nil?
			# Create studylines
		end

		
		#lines = File.new('db/student_data.csv', "r:ISO-8859-1").to_i
		#
		#puts lines.split('\n')[1]
		
		#lines = File.new('db/student_data.csv', "r:ISO-8859-1").readlines
		#puts lines
		#lines = IO.readlines('db/student_data.csv')
		#puts lines
		#lines.each_with_index do |line,i|
		#	
	  #  values = line.strip.split('\n')
	  #  puts "ID: #{values[0]}"
	  #end
	end
	
	desc "Import student data from csv"
  task :course_data, [:filename] => :environment do |t,args|
		lines = IO.readlines('db/student_data.csv', "r:ISO-8859-1")
		#lines = File.new('db/student_data.csv', "r:ISO-8859-1").readlines
		lines.each do |line|
	    params = {}
	    values = line.strip.split(';')
	    puts values
	  end
	end
end