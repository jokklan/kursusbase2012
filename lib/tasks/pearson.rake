namespace :analyse do
	desc "Calculate the pearson coefficient for all students"
	task :recommendations => :environment do |t,args|
		n = 100 	# top N are chosen to reccomend courses
		sim = {} 	# Similarity hash
		# Calculate pearson coefficient between all students
		start_time = Time.now
		# Counting students with course-data
		s_with_c_data = 0
		#student_data = 
		StudentData.all.each do |sd|
			s_with_c_data += 1 if sd.courses.count > 0
		end
		puts "Students with course data: #{s_with_c_data}"
		
		
		
		student = Student.find_by_student_number(ENV['STUDENT_NUMBER'])
		if student
			students = Student.where(:student_number => ENV['STUDENT_NUMBER'])
		else
			students = []
			return
		end
		students.all.each do |a|
		
			# Get students a
			start_time = Time.now
			procent_ind = 0
			puts "# Student: #{a.student_number}"
			puts "Calculating similarity coefficients"
			sim[a] = {}
			index = 0
			StudentData.all.each do |b|
				
				if b.courses.count > 0
					# Get student b (a != b)
					if (a != b) || (not sim[b].nil?)
						
						# Cases: 11 - both has, 00 no one has, 10 only a has, 00 only b has
						case10 = 0
						case01 = 0
						case11 = 0
						case00 = 0
					
						courses_a_had = a.courses.count # courses a has taken
						courses_b_had = b.courses.count # courses b has taken
						no_of_courses = Course.all.count
						
						# counting case11 and case10 by going through all course a has taken
						a.courses.each do |course_a_had|
							a_had = true
							b_had = false
							
							if b.courses.include? course_a_had
								case11 += 1
							else
								case10 += 1
							end
						end
						
						# counting case01 by going through all course b has taken
						b.courses.each do |course_b_had|
							if not a.courses.include?(course_b_had)
								case01 += 1
							end
						end	
						
						# case00 must be all the courses which hasn't been counted
						case00 = no_of_courses - case01 - case11 - case10
						
						# tests if sim_coeff can be calculated
						if courses_b_had > 0
						
							# Calculating means
							mean_a = Float(courses_a_had) / Float(no_of_courses)
							mean_b = Float(courses_b_had) / Float(no_of_courses)
							#puts "mean_a: #{mean_a}"
							
							## Calculating numerator
							numerator = (1 - mean_a)*(0 - mean_b)*case10 + (0 - mean_a)*(1 - mean_b)*case01 + (1 - mean_a)*(1 - mean_b)*case11 + (0 - mean_a)*(0 - mean_b)*case00
							#puts numerator
							
							## Calculating denominator
							denominator_a = (case11 + case10)*(1 - mean_a)**2.0 + (case00 + case01)*(0 - mean_a)**2.0
							denominator_b = (case11 + case01)*(1 - mean_b)**2.0 + (case00 + case10)*(0 - mean_b)**2.0
							#puts denominator_a
							#puts denominator_b
							
							# Calculate pearson similarity coefficient
							if (denominator_a < 0 or denominator_b < 0)
								puts "### denominator < 0 ###"
								puts "numerator: #{numerator}"
								puts "denominator_a: #{denominator_a}"
								puts "denominator_b: #{denominator_b}"
							else
								sim[a][b] = numerator / (Math.sqrt(denominator_a)*Math.sqrt(denominator_b))
								
								# TEST sim coefficient
								if sim[a][b] < -1 or sim[a][b] > 1
									puts "Sim coefficient not in the interval [-1;1]"
									throw :error
								end
								
								
								#sqrt_a = Math.sqrt(denominator_a)
								#sqrt_b = Math.sqrt(denominator_b)
								#puts "### denominators > 0 ###"
								#puts "numerator: #{numerator}"
								#puts "denominator_a: #{denominator_a}"
								#puts "sqrt(d_a): #{sqrt_a}"
								#puts "denominator_b: #{denominator_b}"
								#puts "sqrt(d_b): #{sqrt_b}"
								#puts "courses_b_had: #{courses_b_had}"
								
								#puts sim[a][b]
							end
						end
					end	
					print "|" if index == 0 || index == s_with_c_data - 1
	        if Integer(Float(index) % (Float(s_with_c_data) / 100)) == 0
	          print "="
	          procent_ind += 1
	          print "#{procent_ind}%" if procent_ind % 10 == 0
	        end	
					
					index += 1
				end		
			end
			puts ""
			end_time = Time.now
			elapsed = (end_time - start_time)
			puts "time spend calculating sim coeff: #{elapsed}"

			sim_coeff_a = sim[a].sort {|a,b| b[1]<=>a[1]}
			# Calcuate reccomendations
			
			course_recs = {}
			i = 0
			n_values = 300
			sim_coeff_a.each do |key,val|
				break if i >= n_values
				key.courses.each do |course|
					course_recs[course.id] = 0 if course_recs[course.id].nil?
					course_recs[course.id] += 1
				end		
				i += 1		
			end	
			
			recs = course_recs.sort {|a,b| b[1]<=>a[1]}
			puts "Recommendations:"
			recs.each do |course_id, value|
				course = Course.find(course_id)
				puts "#{course.course_number} - #{value} recommendations" unless not a.should_be_recommended(course)
				if a.should_be_recommended(course)
					a.course_recommendations << CourseRecommendation.new(:course_id => course.id, :priority_value => value)
				end
			end
			
			#puts "Similarity coefficients for a"
			#sim_coeff_a.each do |key,val|
			#	puts "sim(#{key.id}) = #{val}"
			#end

		end
		
		# Count all cases
		#Course.where(:active => true).each do |course|
		#	a_has = false
		#	b_has = false
		#	no_of_courses += 1
		#	if a.courses.include? course
		#		courses_a_had += 1
		#		a_has = true
		#	end
		#	if b.courses.include? course
		#		courses_b_had += 1
		#		b_has = true
		#	end
		#	if !a_has && !b_has # no one have had
		#		case00 += 1
		#	elsif a_has && b_has # both have had
		#		case11 += 1
		#	elsif a_has # only a have had
		#		case10 += 1
		#	else # only b have had
		#		case01 += 1
		#	end
		#end
		#
		## TEST
		#if false
		#	puts "Testing"
		#	# case the sum of all cases should be equal to the number of courses
		#	puts "case: the sum of all cases should be equal to the number of courses"
		#	if no_of_courses == (case00 + case11 + case01 + case10)
		#		puts "TEST PASSED"
		#	else
		#		puts "TEST FAILD"
		#		cases = (case00 + case11 + case01 + case10)
		#		puts "#{no_of_courses} != #{cases}"
		#	end
		#end
		
		
			
		# rec_courses = {}
		# n.times do |i|
		# 	rec_courses[]
		# end
		# For all students 
			# Get students a - find N students with the highest PC, which isn't equal to 0
			
				
					
		
		# Collect and count all courses and save in database for the N students, which student u hasn't taken
		
		# Recommend the courses with highest count
		
		
		
		
		
		
		
		
		
		# Calculating similarity coefficient for all users
		#StudentData.all.each do |u|
			
			
			
			# Comparing with all other students
			# StudentData.all.each do |v|
			# 	sim[u] = {}
			# 	# Checking if already exists
			# 	if u.id != v.id && sim[u][v].nil?
			# 		
			# 		
			# 		sim[u][v] = Random.new(1234)
			# 		
			# 		# Calculate similarity coefficient
			# 		puts sim[u][v]
      # 
			# 		# Save coefficient
			# 		
			# 	end
			# end
		#end
	end
end