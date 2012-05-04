namespace :pearson do
	desc "Calculate the pearson coefficient for all students"
	task :sim_coeff => :environment do |t,args|
		n = 100 	# top N are chosen to reccomend courses
		sim = {} 	# Similarity hash
		# Calculate pearson coefficient between all students
		Student.all.each do |a|
			# Get students a
			StudentData.where(:field_of_study_id => 7).each do |b|
				# Get student b (a != b)
				if (a != b) || (not sim[b].nil?)
					sim[a] = {}
					# Cases: 11 - both has, 00 no one has, 10 only a has, 00 only b has
					case10 = 0
					case01 = 0
					case11 = 0
					case00 = 0
				
					courses_a_had = 0
					courses_b_had = 0	
					no_of_courses = 0						
					
					# Count all cases
					Course.all.each do |course|
						a_has = false
						b_has = false
						no_of_courses += 1
						if a.courses.include? course
							courses_a_had += 1
							a_has = true
						end
						if b.courses.include? course
							courses_b_had += 1
							b_has = true
						end
						if !a_has && !b_has # no one have had
							case00 += 1
						elsif a_has && b_has # both have had
							case11 += 1
						elsif a_has # only a have had
							case10 += 1
						else # only b have had
							case01 += 1
						end
					end
					
					# TEST
					if false
						puts "Testing"
						# case the sum of all cases should be equal to the number of courses
						puts "case: the sum of all cases should be equal to the number of courses"
						if no_of_courses == (case00 + case11 + case01 + case10)
							puts "TEST PASSED"
						else
							puts "TEST FAILD"
							cases = (case00 + case11 + case01 + case10)
							puts "#{no_of_courses} != #{cases}"
						end
					end
					# TEST END
					
					# Calculating means
					mean_a = Float(courses_a_had) / Float(no_of_courses)
					mean_b = Float(courses_b_had) / Float(no_of_courses)
					
					# Test
					#puts "mean_anders: #{mean_a}"					
					#
					## Calculating numerator
					#numerator = (1 - mean_a)*(0 - mean_b)*case10 + (0 - mean_a)*(1 - mean_b)*case01 + (1 - mean_a)*(1 - mean_b)*case11 + (0 - mean_a)*(0 - mean_b)*case00
					#puts numerator
					#
					## Calculating denominator
					#denominator_a = (case11 + case10)*(1 - mean_a)^2 + (case00 + case01)*(0 - mean_a)^2
					#denominator_b = (case11 + case01)*(1 - mean_b)^2 + (case00 + case10)*(0 - mean_b)^2
					#
					## Calculate pearson similarity coefficient
					#sim[a][b] = numerator / (Math.sqrt(denominator_a)*Math.sqrt(denominator_b))
					#puts sim[a][b]
				end				
			end
		end
		
		
			
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