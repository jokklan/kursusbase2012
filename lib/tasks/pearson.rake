namespace :pearson do
	desc "Calculate the pearson coefficient for all students"
	task :sim_coeff => :environment do |t,args|
		sim = {}
		
		# Calculating similarity coefficient for all users
		#StudentData.all.each do |u|
		u = Student.
			
			# Comparing with all other students
			StudentData.all.each do |v|
				sim[u] = {}
				# Checking if already exists
				if u.id != v.id && sim[u][v].nil?
					
					
					sim[u][v] = Random.new(1234)
					
					# Calculate similarity coefficient
					puts sim[u][v]

					# Save coefficient
				end
			end
		#end
	end
end