namespace :analyse do
	desc "Calculate the pearson coefficient for all students"
	task :recommendations => :environment do |t,args|
		n = 100 				# top N are chosen to reccomend courses
		sim = {} 				# Similarity hash
		debug = false		# debug
		s_with_c_data = StudentData.count
		puts "Students with course data: #{s_with_c_data}"
		
		u = Student.find_by_student_number(ENV['STUDENT_NUMBER'])
		return if u.nil?
		
		# Get students a
		total_start_time = Time.now
		start_time = Time.now
		procent_ind = 0
		puts "# Student: #{u.student_number}"
		
		# adding all courses a had to the hash
		courses_u_had = {}
		sim = {}
		u.courses.each {|c| courses_u_had[c] = true }
		puts courses_u_had
		
		performance = {
			:cases => [],
			:means => [],
			:numerator => [],
			:denominators => [],
			:sim_coeff => [], 
			:recommendations => [],
			:recommendation_sort => []
		}
		
		# Calculating similarity coefficients
		puts "Calculating similarity coefficients"		
		StudentData.all.each_with_index do |s, index|
			# Get student b (which has more than 0 courses)
			if s.courses.count > 0
				
				start_time = Time.now #cases
				# amount of different cases
				case10 = 0 # case where only student a have had the course
				case01 = 0 # case where only student b have had the course
				case11 = 0 # case where both have had the course
				case00 = 0 # case where no one have had the course
				
				# data to calculate pearson
				course_amount_u = u.courses.count 	# courses a has taken
				course_amount_s = s.courses.count 	# courses b has taken
				no_of_courses = Course.all.count	# no of courses on DTU
				
				# calculating cases by going through b's courses
				both_cache = [] # to keep courses both have had
				s.courses.each do |course_s_had|
					if courses_u_had[course_s_had] == true
						case11 += 1
						both_cache << course_s_had
					else
						case01 += 0
					end
				end
				
				# case10 must be all courses in courses_u_had which are not in the both_cache
				case10 = course_amount_u - both_cache.count
				
				# case00 must be all the courses which hasn't been counted
				case00 = no_of_courses - case01 - case11 - case10
				performance[:cases] << (Time.now - start_time)
				
				
				# Calculating means
				start_time = Time.now # means
				mean_u = Float(course_amount_u) / Float(no_of_courses)
				mean_s = Float(course_amount_s) / Float(no_of_courses)
				performance[:means] << (Time.now - start_time)
				
				## Calculating numerator
				start_time = Time.now # numerator
				# OLD VERSION: numerator = (1 - mean_u)*(0 - mean_s)*case10 + (0 - mean_u)*(1 - mean_s)*case01 + (1 - mean_u)*(1 - mean_s)*case11 + (0 - mean_u)*(0 - mean_s)*case00
				numerator = mean_u*mean_s*no_of_courses - mean_u*(case11+case01) - mean_s*(case11+case10)+case11
				#puts numerator
				performance[:numerator] << (Time.now - start_time)
				
				## Calculating denominators
				start_time = Time.now # denominator
				denominator_u = case11 + case10 - (mean_u**2.0)*no_of_courses
				denominator_s = case11 + case01 - (mean_s**2.0)*no_of_courses
				
				# OLD VERSIONS
				#denominator_u2 = (case11 + case10)*(1 - mean_u)**2.0 + (case00 + case01)*(0 - mean_u)**2.0
				#denominator_s2 = (case11 + case01)*(1 - mean_s)**2.0 + (case00 + case10)*(0 - mean_s)**2.0
				
				performance[:denominators] << (Time.now - start_time)
				
				# Calculate pearson similarity coefficient
				if (denominator_u < 0 or denominator_s < 0)
					#puts "### denominator < 0 ###"
					#puts "numerator: #{numerator}"
					#puts "denominator_u: #{denominator_u}"
					#puts "denominator_s: #{denominator_s}"
				else
					start_time = Time.now # sim
					performance[:sim_coeff] << (Time.now - start_time)
					sim[s] = numerator / (Math.sqrt(denominator_u)*Math.sqrt(denominator_s))
					#puts "Old pearson:"
					#puts numerator / (Math.sqrt(denominator_u2)*Math.sqrt(denominator_s2))
					#puts "New pearson:"
					#puts numerator / (Math.sqrt(denominator_u)*Math.sqrt(denominator_s))
					
					# TEST sim coefficient
					if sim[s] < 0 
						puts sim[s]
					end
					if sim[s] < -1 or sim[s] > 1
						puts "Sim coefficient not in the interval [-1;1]"
						throw :error
					end
					
					
					#sqrt_u = Math.sqrt(denominator_u)
					#sqrt_s = Math.sqrt(denominator_s)
					#puts "mean_u: #{mean_u}"
					#puts "mean_s: #{mean_u}"
					#puts "### denominators > 0 ###"
					#puts "numerator: #{numerator}"
					#puts "denominator_u: #{denominator_u}"
					#puts "sqrt(d_u): #{sqrt_u}"
					#puts "denominator_s: #{denominator_s}"
					#puts "sqrt(d_s): #{sqrt_s}"
					#puts "course_amount_s: #{course_amount_s}"
					
					#puts sim[s]
				end
			end	
			print "|" if index == 0 || index == s_with_c_data - 1
			if Integer(Float(index) % (Float(s_with_c_data) / 100)) == 0
				print "="
			  procent_ind += 1
			  print "#{procent_ind}%" if procent_ind % 10 == 0
			end		
		end
	
		start_time = Time.now
		sim_coeff_a = sim.sort {|a,b| b[1]<=>a[1]}
		# Calcuate reccomendations
		
		course_recs = {}
		i = 0
		n_values = 300
		sim_coeff_a.each do |key,val|
			break if i >= n_values
			if val == 1
				key.courses.each do |course|
					course_recs[course.id] = 0 if course_recs[course.id].nil?
					course_recs[course.id] += 1
				end	
			else
				n_values += 1 # taking one more in concideration
			end
			i += 1		
		end
		performance[:recommendations] << (Time.now - start_time)	
		
		start_time = Time.now
		recs = course_recs.sort {|a,b| b[1]<=>a[1]}
		puts "Recommendations:"
		recs.each do |course_id, value|
			course = Course.find(course_id)
			if u.should_be_recommended(course) and course.active?
				u.course_recommendations << CourseRecommendation.new(:course_id => course.id, :priority_value => value)
			end
		end	
		performance[:recommendation_sort] << (Time.now - start_time)
		
		puts "\nSim coefficient calculation done"
		puts "Analysing sim-coeff calculation..."
		puts "TOTAL #{(Time.now - total_start_time).to_f} - COUNT: #{StudentData.all.count}"
		performance.each do |key, array|
			total = array.inject{ |sum, el| sum + el }.to_f 
			average = total / array.size
			puts "#{key.upcase}: times: #{array.size} - average: #{average} - total: #{total}"
		end
		puts "Analysing done"
		
	end
end