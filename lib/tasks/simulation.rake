desc "Simulate test data"
namespace :simulate do
  task :users => :environment do
    # Create 
    software = FieldOfStudy.create(:name => "Software")
    
    ids_used = []
    
    100.times do 
      begin
        random_id = "70" + rand(1000..9999).to_s
      end while ids_used.include? random_id
      ids_used.insert(random_id)
      puts random_id
      #User.create(:user_id => random_id.to_i, :direction_id => software.id)
    end
  end
  
  task :coursetekken => :environment do
	DIST_PRECISION = 100.0
    distribution = {
      :semester2_1 => {
        '02402' => 0.25,
        '02403' => 0.60,
        '02405' => 0.15
      },
      
      :semester2_2 => {
        '02601' => 0.05,
        '01227' => 0.40,
        '42415' => 0.02,
        '42610' => 0.01,
        '02633' => 0.17,
        '30010' => 0.35
      },
      
      :semester3_1 => {
        '10022' => 0.5,
        '10020' => 0.5
      },
      
      :semester3_2 => {
        '10035' => 0.15,
        '41101' => 0.01, 
        '02110' => 0.5,  
        '02162' => 0.04, 
        '02501' => 0.02, 
        '42415' => 0.02, 
        '42619' => 0.02, 
        '02601' => 0.04,   
        '02405' => 0.2
      },
      
      :semester3_3 => {
        '02266' => 0.5,
        '31070' => 0.05,
        '02507' => 0.01,
        '31385' => 0.25,
        '01330' => 0.19
      },
      
      :semester4_1 => {
        '10022' => 0.5,
        '10020' => 0.5
      },
      
      :semester4_2 => {
        '42430' => 0.03,
        '01227' => 0.25,
        '02601' => 0.04,
		'01410' => 0.15,
		'41101' => 0.03,
        '02170' => 0.3,
        '02631' => 0.05,
        '01035' => 0.05,
        '02180' => 0.2,
        '42415' => 0.01,
        '42610' => 0.02,
        '26027' => 0.07
      },

	  :semester5_1 => {
	    '02811' => 0.05,
	    '10022' => 0.02,
	    '10020' => 0.03,
	    '02631' => 0.03,
	    '30550' => 0.05,
	    '26027' => 0.02,
	    '02110' => 0.05,
	    '02154' => 0.10,
	    '34311' => 0.05,
	    '02162' => 0.10,
	    '02350' => 0.10,
	    '42415' => 0.01,
	    '02402' => 0.01,
	    '02601' => 0.01,
	    '42610' => 0.01,
	    '42113' => 0.07,
	    '10044' => 0.01,
	    '02405' => 0.02,
	    '02561' => 0.20,
	    '02815' => 0.04,
	    '02239' => 0.01,
	    '02562' => 0.01
	  },
	
	  :semester5_2 => {
        '02165' => 0.3,
        '02266' => 0.2,
        '02243' => 0.1,
        '31385' => 0.4
      },

      :semester6_1 => {
	    '02283' => 0.05,
	    '42430' => 0.02,
	    '02576' => 0.03,
	    '10022' => 0.03,
	    '02601' => 0.05,
	    '01227' => 0.02,
	    '02564' => 0.05,
	    '10020' => 0.10,
	    '02604' => 0.05,
	    '01410' => 0.10,
	    '41101' => 0.10,
	    '02565' => 0.01,
	    '02241' => 0.01,
	    '02281' => 0.01,
	    '02170' => 0.01,
	    '42610' => 0.07,
	    '42415' => 0.01,
	    '02631' => 0.02,
	    '02285' => 0.17,
	    '02233' => 0.04,
	    '30530' => 0.01,
	    '10044' => 0.01,
	    '34310' => 0.01,
	    '02405' => 0.01,
	    '26027' => 0.01
	  },
    } 
	user = User.first
	distribution.each do |key, semester|
		
		# Get unique distribution numbers first
		distribs = semester.values.uniq
		distmap = {}
		
		User.all.each do |user|
			i = rand(DIST_PRECISION/2 + 1)/DIST_PRECISION

			#puts user.id
			distribs.each do |dist|

				distmap[dist] = [] if not distmap.include? dist
				if i <= dist
					puts i.to_s + ' <= ' + dist.to_s
					distmap[dist] << user.id
					break
				else
					puts 'i = ' + i.to_s + ' - ' + dist.to_s + ' = ' + (i - dist).round(2).to_s
					i = (i - dist).round(2) # FIGHT!
				end

			end
		end
		
		puts distmap
		
		#sorted_semester.each do |key, dist|
			
			#puts "#{key} - #{dist}"
			#has_no_course_at_sem = true
			#current_course = Course.find_by_course_number(key)
			#begin
		    #	random_int = rand(1)
			#end while has_no_course_at_sem
			# 
		#end
		
	end
    
  end
  
  
end