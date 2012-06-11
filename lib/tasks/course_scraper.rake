# encoding: utf-8
namespace :scrape do
	require 'rails'
	require 'pp'
  desc "Import courses from kurser.dtu.dk"
  task :courses, [:seed] => :environment do |t,args|
    args.with_defaults(:seed => 'true')
    require 'mechanize'
    if args.seed == 'true' || args.seed == 1
      db_seed = 1 # db_seed = true for seeding database with scraping content (debug needs to be false)
    end
    
    # Reset database if seeding
    if ENV['reset']
      puts "Restarting database"
      Rake::Task['db:reset'].invoke
    end

		# Set debug (printing course attributes)
		if ENV['debug']
			db_seed 			 = false
			db_debug 			 = true
			test_db_types = false
		end
		
		# if ENV['prereq']
		# 	puts "Scraping prerequisites"
		# 	scrape_prereq = true
		# 	db_seed = false
		# end
		
		
    # Scraping for each language
    languages = [:da, :en]
    languages.each do |language|
      
      # Setting language
      I18n.locale = language			   
    
      # URL's for different searches on kurser.dtu.dk
      url_dtu      = "http://www.kurser.dtu.dk/"
      url_civil    = "http://www.kurser.dtu.dk/search.aspx?lstType=DTU_MSC%C2%A4&YearGroup=2011-2012&btnSearch=Search"
      url_software = "http://www.kurser.dtu.dk/search.aspx?lstTeachingPeriod=E1;E2;E3;E4;E5;E1A;E2A;E3A;E4A;E5A;E1B;E2B;E3B;E4B;E5B;E&lstType=Teknologisk%20linjefag,%20Softwareteknologi&YearGroup=2011-2012&btnSearch=Search"
      url_test2    = "http://www.kurser.dtu.dk/search.aspx?lstType=DTU_FOOD_SCI%C2%A4&YearGroup=2011-2012&btnSearch=Search"
			url_math     = "http://www.kurser.dtu.dk/search.aspx?lstDepartment=1&YearGroup=2011-2012&btnSearch=Search"
			url_java		 = "http://www.kurser.dtu.dk/search.aspx?txtSearchKeyword=Java&YearGroup=2011-2012&btnSearch=Search"
			url_inform	 = "http://www.kurser.dtu.dk/search.aspx?lstDepartment=1,2&lstType=DTU_MSC%C2%A4&YearGroup=2011-2012&btnSearch=Search"
    
      # Fetching the URL
      agent = Mechanize.new
      url = url_civil
      page = agent.get(url)
    
      # Saving each link of the course in the array
      array = []
			course_schedules = {}
      agent.page.links_with(:href => %r{\d{5}\.aspx\?menulanguage=.*}).each do |link|
        link_url = link.href.to_s
				schedule_regex = %r{^((E|F)([0-9])(A|B)?|Efterår|Forår|Spring|Autumn|Fall|January|Januar|June|Juni)}.match(link.text)
				if not schedule_regex.nil?
					course_number_regex = %r{(\d{5})}.match(link.href.to_s)
					course_schedules[course_number_regex[1].to_i] = link.text
				end
        link_url = link_url.gsub("en","da") if language == :da
        link_url = link_url.gsub("da","en") if language == :en
        array << link_url unless array.include?(link_url)
      end
    
      # Error hash used for testing data-types
      error = {}
    
      # Console display
      puts "## Scraping courses ##"
      puts "> Language = #{language}"
      puts "> URL = #{url}"
      puts "> Number of courses = #{array.length}\n"
      course_amount = array.length
      procent_ind = 0
    
      # Taking each link and scraping
      array.each_with_index do |e, i|   
				
				# Storing the current info
        current_course = {}
        current_course_teachers = []
        current_course_types_head = []
        current_course_types = []
        current_course_keywords = []
        current_course_institute = {}
				current_course_prereq = {}
				current_course_objectives = []
				current_course_schedules = []
          
        other_info = {}
				
				# Rescuing error if trouble connecting to the dtu.dk
				page_error = false
				begin
					page = agent.get("#{url_dtu}#{e}")
				rescue
					page_error = true
				end
        
        # The table with content
        table = page.search("div.CourseViewer table")[0]
        table_rows = table.search("tr")
      
        # First row (title and course number)
        row1 = table_rows[0]
          
        # Title
        title = row1.search("h2").text
        current_course[:title] = %r{^\d{5}.(.+)}.match(title)[1].to_s
        current_course[:course_number] = %r{^\d{5}}.match(title).to_s.to_i
				current_course[:active] = true
				
				# Top Comment
				#puts table
        if table.search("tr:nth-child(2) .normal").length == 2
          current_course[:top_comment] = table_rows[2].search("p").text
        end      
      
        # Content 
        content_table = page.search("div.CourseViewer table")[3]
      
        # Content table rows    
        content_rows = content_table.search("tr")

				# Another index, if new versions
				if content_rows[2].nil?
	        content_table = page.search("div.CourseViewer table")[2]
	        content_rows = content_table.search("tr")
				end
          
        # Title på et andet sprog (row 1)
        other_info[:title_other_language] = content_rows[1].search("td")[1].text.strip.chomp
      
        # Sprog (row 2)
        current_course[:language] = content_rows[2].search("td")[1].text.strip.chomp
      
        # ECTS points (row 3)
        current_course[:ects_points] = content_rows[3].search("td")[1].text.strip.chomp
      
        # Course types (row 5)
        # Her angives, om det er Civil, Diplom, Levnedsmiddel, Ph.d. etc.
        column_text = content_rows[4].search("table td")[0].to_s.chomp.strip
        current_course_types_head = column_text[4,(column_text.length - 9)].chomp.strip.split("<br>")
      
        # Under åben universitet
        # If the course is 'Taught under open university' a row for that is made
        # it has the unique css selector: '.value td.value', so this is used for indicator.
        if !(content_table.search(".value td.value").text[0..5] == "Kurset")
          current_course[:open_education] = true
        end
      
        # More course types
        # Her angives, hvis det er linjefag, specialisering eller generel retningskompetence
        # Der skal tilføjes noget mere struktur til databasen. Både for søgnings og sorteringsens skyld.
        column = content_table.search("#studiebox td")[0]
        if !column.nil?
          column_text = column.to_s.chomp.strip
          current_course_types = column_text[4,(column_text.length - 9)].chomp.strip.split("<br>")
        end
      
        # Hash's with recognizable titles (so the scraper can identify the different columns)
				# :point_block, :qualified_prereq, :optional_prereq, :mandatory_prereq
        course_attributes = { :da => {
                                      :mandatory => {
                                                    :teaching_form => "Undervisningsform:",
                                                    :duration => "Kursets varighed:",
                                                    :former_course => "Tidligere kursus:",
                                                    :participant_limit => "Deltagerbegrænsning:",
                                                    :registration => "Tilmelding:"
                                                    },
                                      :evaluation => {
                                                    :exam_schedule => "Eksamensplacering:",
                                                    :exam_form => "Evalueringsform:",
                                                    :exam_duration => "Eksamens varighed:",
                                                    :exam_aid => "Hjælpemidler:",
                                                    :evaluation_form => "Bedømmelsesform:"
                                                    },
                                      :prerequisites => {
                                                    :point_block => "Pointspærring:",
                                                    :mandatory_prereq => "Obligatoriske forudsætninger:",
                                                    :qualified_prereq => "Faglige forudsætninger:",
                                                    :optional_prereq => "Ønskelige forudsætninger:"
                                                    },
                                      :institute => {
                                                    :institute => "Institut:",
                                                    },
                                      :text_att => {
                                                    :course_objectives => "Overordnede kursusmål:",
                                                    :content => "Kursusindhold:",
                                                    :litteratur => "Litteratur:",
                                                    :remarks => "Bemærkninger:"
                                                    },
                                      :learn_objectives => {
                                                    :learn_objectives => "Læringsmål:"
                                                    },
                                      :responsible => {
                                                    :teachers => "Kursusansvarlig:"
                                                    },
                                      :homepage => {
                                                    :homepage => "Kursushjemmeside:"
                                                    },
                                      :keywords => {
                                                    :keywords => "Nøgleord:"
                                                    },
																			:schedule => {
																										:schedule => "Skemaplacering:"
																			}
                                                  
                                    
                              },
                              :en => {
                                      :mandatory => {
                                                    :schedule_note => "Schedule:",
                                                    :teaching_form => "Scope and form:",
                                                    :duration => "Duration of Course:",
                                                    :former_course => "Previous Course:",
                                                    :participant_limit => "Participants restrictions:",
                                                    :registration => "Registration Sign up:"
                                                    },
                                      :evaluation => {
                                                    :exam_schedule => "Date of examination:",
                                                    :exam_form => "Type of assessment:",
                                                    :exam_duration => "Exam duration:",
                                                    :exam_aid => "Aid:",
                                                    :evaluation_form => "Evaluation:"
                                                    },
                                      :prerequisites => {
                                                    :point_block => "Not applicable together with:",
                                                    :mandatory_prereq => "Mandatory Prerequisites:",
                                                    :qualified_prereq => "Qualified Prerequisites:",
                                                    :optional_prereq => "Optional Prerequisites:"

                                                    },
                                      :institute => {
                                                    :institute => "Department:",
                                                    },
                                      :text_att => {
                                                    :course_objectives => "General course objectives:",
                                                    :content => "Content:",
                                                    :litteratur => "Course literature:",
                                                    :remarks => "Remarks:"
                                                    },
                                      :learn_objectives => {
                                                    :learn_objectives => "Learning objectives:"
                                                    },
                                      :responsible => {
                                                    :teachers => "Responsible:"
                                                    },
                                      :homepage => {
                                                    :homepage => "Home page:"
                                                    },
                                      :keywords => {
                                                    :keywords => "Keywords:"
                                                    },
																			:schedule => {
																										:schedule => "Schedule:"
																			}
                                    
                                    
                                      }
                            
                             }
      
        # Taking each row in the nice tables of kurser.dtu.dk
        content_rows.each_with_index do |row, row_i|
					
					# Getting attribute title and matching
          att_column = row.search("td")
          att_title = att_column[0].text.chomp.strip
        
          # Mandatory attributes
          course_attributes[language][:mandatory].each do |key, att|
            if att_title == att
              current_course[key] = att_column[1].text.strip.chomp
            end
          end

					# Schedule
          if course_attributes[language][:schedule][:schedule] == att_title
						# Adding schedule from former scrape
						schedule = course_schedules[current_course[:course_number]]
						current_course[:schedule] = schedule if not schedule.nil?
						string = att_column[1].text.strip.chomp
						
						# Scraping schedule notes
						
						if string.nil? or schedule == string
							schedule_note = nil
						elsif schedule.nil?
							schedule_note = string
						else
							if string[schedule.length..string.length].nil?
								schedule_note = nil
							else
								schedule_note = string[schedule.length..string.length].gsub(/^[:;,.\s]+/,'')
							end
						end
						current_course[:schedule_note] = schedule_note
						
						# Scraping schedule blocks
						schedules = string.scan(%r{([E|F]\d[A|B]?|Januar|Juni|januar|juni)}).to_a	
						schedules.each do |s|
							sch = s.first
							sch.gsub!('januar','Januar')
							sch.gsub!('juni','Juni')
							if %r{F\d{1}\z}.match(sch) or %r{E\d{1}\z}.match(sch)
								current_course_schedules << "#{sch}A"
								current_course_schedules << "#{sch}B"
							else
								current_course_schedules << sch
							end
						end
					end
        
          # Evaluation attributes
          course_attributes[language][:evaluation].each do |key, att|
            if att_title == att
              current_course[key] = att_column[1].text.chomp.strip
							#puts current_course[key] if key == :exam_schedule
            end
          end
        
          # Prerequisites
					if language == :da
          	course_attributes[language][:prerequisites].each do |key, att|
							has_letters = false
          	  if att_title == att
								# Checking if column exists
          	    column = att_column[1].text
          	    if !column.empty?
									#current_course[key] = 
									
									#find_letters = %r{([a-zA-Z])}.match(column)
									has_letters = true if !%r{([a-zA-Z])}.match(column).nil?
									and_split_courses = [] # Array to hold each course-group seperated by .
									
									# Splits the column by .
          	      and_split = column.split('.')
          	      and_split.each do |req_and|
										
										# Splits each part seperated by /
										or_split = req_and.split('/')
										or_split_courses = [] # Array to hold each course-group seperated by /
	        	      	or_split.each do |req_or|
											# A regex to match digits of length 5 (course number!)
											course_digits = %r{(\d{5}).*}.match(req_or.chomp.strip)
											or_split_courses << course_digits[1].to_s.chomp.strip if !course_digits.nil?
										end
										and_split_courses << or_split_courses if !or_split_courses.empty?
          	      end
									# Adding to the database
									current_course_prereq[key] = and_split_courses if !and_split_courses.empty?
									if !has_letters
										prereq_string = ''
										and_split_courses.each do |and_split|
											and_split.each do |or_split|
												prereq_string << or_split
												prereq_string << "/" if or_split != and_split.last
											end
											prereq_string << "." if and_split != and_split_courses.last
										end
										current_course[key] = prereq_string
										#puts prereq_string
									end
									#puts column.chomp.strip if has_letters
          	    end
								
          	  end
          	end
					end
        
          # Institute
          course_attributes[language][:institute].each do |key, att|
            if att_title == att
              institute = att_column[1].text.chomp.strip
              current_course_institute[:title] = institute[3,institute.length]
              current_course_institute[:dtu_institute_id] = institute[0,2]
            end
          end
        
          # Text attributes
          course_attributes[language][:text_att].each do |key, att|
            if att_title == att
              current_course[key] = content_rows[row_i + 1].search("td").text.chomp.strip
            end
          end
        
          # Learn objectives - saved as an array (of objectives)
          course_attributes[language][:learn_objectives].each do |key, att|
            if att_title == att
              objective_list = content_rows[row_i + 2].search("td ul li")
                objectives = []
                objective_string = ''
                objective_list.each do |o|
                  objectives << o.text.chomp.strip unless objectives.include?(o.text.chomp.strip)
                end
								
                objectives.each_with_index do |oa,i|
                  if i > 0
                    objective_string << ">#{oa}"
                  else
                    objective_string << oa
                  end
                end
                current_course[key] = objective_string
            end
          end
        
          # The responsible teachers
          course_attributes[language][:responsible].each do |key, att|
            if att_title == att
							ids = {}
              content_rows[row_i + 1].search("td a.menulink").each do |link|
                if !%r(mailto:.*).match(link[:href])
                  t_id = %r(http:\/\/www.dtu.dk\/Service\/Telefonbog\.aspx\?id=(.*)&type=person&lg=showcommon).match(link[:href].chomp.strip)[1]
                  t_name = link.text.chomp.strip
									ids[t_name] = t_id
									#puts "#{current_course[:course_number]} - #{t_name}"
                  #current_course_teachers << { :name => t_name, :dtu_teacher_id => t_id }
                end
              end
							text = content_rows[row_i + 1].search("td").text
							regex = text.scan(/([A-Z][^\d@,]+), (([\d|\s|[a-zA-Z]]+, [\d|\s|[a-zA-Z]]+), )?(\(\+\d*\).\d*.\d*)?[, ]?(.*@.*)/)
							teachers = []
							regex.each do |teacher|	
								name = teacher[0].strip.gsub("The course is taught by professor ","")
								#puts "#{name} - #{teacher[2]} - #{teacher[3]} - #{teacher[4]} - #{ids[teacher[0].strip]}"
								puts "#{name}" if ids[teacher[0].strip].nil?
								teachers << { :name => name, :location => teacher[2], :phone => teacher[3], :email => teacher[4], :dtu_teacher_id => ids[teacher[0].strip] }
							end
							#pp teachers
            end
          end
        
          # Website / Homepage / Hjemmeside ...
          course_attributes[language][:homepage].each do |key, att|
            if att_title == att
              current_course[key] = att_column[1].at_css("a")[:href]
            end
          end 
        
          # Keywords
          course_attributes[language][:keywords].each do |key, att|
            if att_title == att
							att_column[1].text.split(',').each do |k|
								current_course_keywords << k.strip.chomp
							end
            end
          end
        end # End of column.each
      
        # Testing data types
        string_att = [:title, :language, :registration, :homepage, :duration, :participant_limit, :exam_duration, 
                      :exam_aid, :evaluation_form, :former_course]
        if test_db_types
          current_course.each do |key, att|
            if string_att.include?(key)
              error[key] = att if att.length > 255 && !error[key]
            end
          end
        end
				
        # Printing debug data
        if db_debug      
          puts "Title: #{current_course[:title]}"
          puts "Course types"
          pp current_course_types_head
          pp current_course_types
          puts "Course attributes:"
          pp current_course
          puts "Teachers:"
          pp current_course_teachers
          puts "Institute:"
          pp current_course_institute          
          puts "Keywords"
          pp current_course_keywords
          puts "####################################"
        end

				# Adding course-relations
				if language == :da
					created_course = Course.find_or_create_by_course_number(current_course[:course_number])
					current_course_prereq.each do |key, att|
						group_no = 1
						att.each do |a|
							a.each do |o|
								course = Course.find_by_course_number(o)
								if course.nil?
									course = Course.create(:course_number => o, :active => false)
								end
								case key
									when :point_block
										#puts "adding blocked courses"
										created_course.point_blocks 				 << CourseRelation.new(:group_no => group_no, :related_course_id => course.id, :related_course_type => 'Blocked')
									when :optional_prereq
										#puts "adding optional courses"
										created_course.advisable_qualifications  << CourseRelation.new(:group_no => group_no, :related_course_id => course.id, :related_course_type => 'Optional')
									when :mandatory_prereq
										#puts "adding mandatory courses"
										created_course.mandatory_qualifications				 << CourseRelation.new(:group_no => group_no, :related_course_id => course.id, :related_course_type => 'Mandatory')
									when :qualified_prereq
										#puts "adding qualified courses"
										created_course.optional_qualifications	   << CourseRelation.new(:group_no => group_no, :related_course_id => course.id, :related_course_type => 'Qualification')
									else
										puts "### ERROR when trying to scrape prerequisites ###"
								end	
								group_no += 1
							end
						end
						created_course.save
					end
				end			
				
				# Creating the courses
        if db_seed
					
					# Finding or creating institute
          created_institute = Institute.find_by_dtu_institute_id(current_course_institute[:dtu_institute_id])
          if created_institute.nil?
            created_institute = Institute.create(current_course_institute)
          else
            created_institute.update_attributes(current_course_institute)
            created_institute.save
          end
          
					# Adding institute to current course
          current_course[:institute_id] = created_institute.id
          
					# Finding or creating course
          created_course = Course.find_by_course_number(current_course[:course_number])
          if created_course.nil?
            created_course = Course.create(current_course)
          else
            created_course.update_attributes(current_course)
            created_course.save
          end

					# Adding objectives
					created_course.learn_objectives = current_course[:learn_objectives]
					
					# Finding or creating teachers
          current_course_teachers.each do |t|
						
            teacher = Teacher.find_or_create_by_dtu_teacher_id(t) 
            created_course.teachers << teacher unless created_course.teachers.include?(teacher)
          end
					
					# Attributes, which should be translated
          if language == :da
						
						# Finding or creating schedule blocks (E1, E2, F3 osv.)
						current_course_schedules.each do |s|
							schedule = Schedule.find_by_block(s)
							created_course.schedules << schedule if not schedule.nil? and not created_course.schedules.include? (schedule)
						end
						
						# Finding or adding keywords
            current_course_keywords.each do |k|
              keyword = Keyword.find_by_title(k)
              keyword = Keyword.create(:title => k) if keyword.nil?
              created_course.keywords << keyword
            end

						# Finding or adding course types
            current_course_types_head.each do |cth|
							cthmap = {
								"Civil- Grundlæggende kursus" => "Grundlæggende civilkursus",
								"Civil- Videregående Kursus"	=> "Videregående civilkursus"
							}
							
							cth = cthmap[cth] if cthmap.include? cth
							course_type = MainCourseType.find_by_title(cth)
							course_type = MainCourseType.create(:title => cth) if course_type.nil?
							created_course.main_course_types << course_type
              #course_type = CourseType.find_by_title_and_course_type_type(cth, "Main")
              #course_type = CourseType.create(:title => cth, :course_type_type => "Main") if course_type.nil? 
              #created_course.main_course_types << course_type
            end

						bachelor_studylines = [
							'Fysik og Nanoteknologi', 
							'Design og Innovation',
							'Miljøteknologi',
							'Produktion og Konstruktion',
							'Elektroteknologi',
							'Medicin og Teknologi',
							'Softwareteknologi',
							'Matematik og Teknologi',
							'Kemi og Teknologi',
							'Byggeteknologi',
							'Bioteknologi',
							'Teknisk Biomedicin',
							'Bioteknologi',
							'IT og Kommunikationsteknologi',
							'Kommunikationsteknologi',
							'Bygningsdesign'
						]

						course_types = {
							'Teknologisk specialisering' => 'Teknologisk specialisering',
							'Teknologisk specialiserng'	 => 'Teknologisk specialisering',
							'Naturvidenskabeligt grundfag' => 'Naturvidenskabeligt grundfag',
							'Teknologisk linjefag' => 'Teknologisk linjefag',
							'Generel retningskompetence' => 'Generel retningskompetence'
						}
						
						flag_types = {
							'Teknologisk specialisering'		=> 'Specialization',
							'Naturvidenskabeligt grundfag'	=> 'Basics',
							'Teknologisk linjefag'					=> 'Main',
							'Generel retningskompetence'		=> 'General'
						}

						# Finding or adding special course types
            current_course_types.each do |ct|
							# Find course_type_type
							course_type_split = ct.split(',')
							# Finding or creating field of study
							fos = FieldOfStudy.find_by_title(course_type_split[1].strip) unless course_type_split[1].nil?
							if fos.nil?
								if course_type_split[1].nil?
									fos = nil
								else
									fos = FieldOfStudy.create(:title => course_type_split[1].strip)
								end
							end
							
							# Finding course type in hash
							if course_types[course_type_split[0]].nil?
								puts "ERROR occured when trying to find course_type title"
								puts "Course Type: #{ct}"
							end
							# Spec Course Type TYPE
							course_type_type = CourseTypeType.find_by_title(course_types[course_type_split[0]])
							course_type_type = CourseTypeType.create(:title => course_types[course_type_split[0]]) if course_type_type.nil? 
							
							# Flag type
							flag_model_type = FlagModelType.find_by_title(flag_types[course_type_type.title])
							flag_model_type = FlagModelType.create(:title => flag_types[course_type_type.title]) if flag_model_type.nil?
							
							# Spec Course type
							## Every bachelor line has basic subjects
							if course_type_type.title == 'Naturvidenskabeligt grundfag'
								bachelor_studylines.each do |fos_name|
									fos = FieldOfStudy.find_by_title(fos_name)	
									fos = FieldOfStudy.create(:title => fos_name) if fos.nil?
									
									ct = SpecCourseType.find_by_course_type_type_id_and_field_of_study_id(course_type_type, fos)
									ct = SpecCourseType.create(:course_type_type => course_type_type, :field_of_study => fos, :flag_model_type => flag_model_type) if ct.nil?
									
									created_course.course_specializations.build(:spec_course_type => ct)
								end
								
								
							else
								ct = SpecCourseType.find_by_course_type_type_id_and_field_of_study_id(course_type_type, fos) unless course_type_split[0].nil?
								ct = SpecCourseType.create(:course_type_type => course_type_type, :field_of_study => fos, :flag_model_type => flag_model_type) if ct.nil?
								created_course.course_specializations.build(:spec_course_type => ct)
							end
            end
          else
						
						# Finding the keyword in english and adding it in danish
            created_course.keywords.with_translations(:da).each_index do |i|
              keyword = created_course.keywords[i]
              keyword.update_attributes(:title => current_course_keywords[i], :locale => language)
              keyword.save
            end

						# Finding the course type in english and adding it in danish
            created_course.main_course_types.with_translations(:da).each_index do |i|
              course_type = created_course.main_course_types[i]
							if not current_course_types_head[i].nil?
              	course_type.update_attributes(:title => current_course_types_head[i], :locale => language)
              	course_type.save
							end
            end

						# ct_popped = {}
						# current_course_types.each {|ct| ct_popped[ct] = false }
						
          	# Finding the special course types in english and adding it in danish
            #created_course.spec_course_types.with_translations(:da).each_index do |i|
            #  course_type = created_course.spec_course_types[i]
						#	if not current_course_types[i].nil?
						#		course_type_split = current_course_types[i].split(',')
            #  	course_type.update_attributes(:title => course_type_split[0].strip, :locale => language)
						#		if not course_type_split[1].nil?
						#			course_type.field_of_study.update_attributes(:title => course_type_split[1].strip, :locale => language)
						#		end
						#	end
            #  course_type.save
            #end

						# ct_popped.each do |ct, popped|
						# 	if not popped
						# 		course_type = CourseType.find_by_title(ct)
						# 	              course_type = CourseType.create(:title => ct, :course_type_type => "Spec") if course_type.nil?
						# 		created_course.spec_course_types << course_type
						# 	end
						# end
          end
        
          # Saving course
          created_course.save
        end

				print "|" if i == 0 || i == course_amount - 1
        if Integer(Float(i) % (Float(course_amount) / 100)) == 0
          print "="
          procent_ind = procent_ind + 1
          print "#{procent_ind}%" if procent_ind % 10 == 0
        end
      
      end
    
      # Link loop end
      if test_db_types
        if error.empty?
          puts "\nNo error on string-datatypes"
        else
          error.each do |key, e|
            puts "DATA-TYPE for attribute #{key} is too long to be a string\nExample: #{e}"
          end
        end
      end
      puts ""
    end			
		# Manual shit
		puts "Doing the manual stuff"
		I18n.locale = :da
		
		# Set up project courses
		project_courses = {
			'Softwareteknologi' => { 2101 => 1, 2121 => 1, 2122 => 1, 42610 => 1},
			'Matematik og Teknologi' => { 2525 => 1, 42610 => 0, 1543 => 0, 1666 => 0, 2101 => 0 }
		}
		
		# Flag model
		flag_model_name = 'ProjectAndGeneral'
		flag_model_type = FlagModelType.find_by_title(flag_model_name)
		flag_model_type = FlagModelType.create(:title => flag_model_name) if flag_model_type.nil?
		
		# Course type
		course_type_name = 'Projekter og almene fag'
		course_type_type = CourseTypeType.find_by_title(course_type_name)
		course_type_type = CourseTypeType.create(:title => course_type_name) if course_type_type.nil?
		
		project_courses.each do |fos_name, c_hash|
			# Field of study
			fos = FieldOfStudy.find_by_title(fos_name)
			fos = FieldOfStudy.create(:title => fos_name) if fos.nil?
			
			# Spec course type
			ct	= SpecCourseType.find_by_course_type_type_id_and_field_of_study_id(course_type_type, fos)
			ct	= SpecCourseType.create(:course_type_type => course_type_type, :field_of_study => fos, :flag_model_type => flag_model_type) if ct.nil?
			
			c_hash.each do |c, optional|
				# Course
				course_number = Integer(c)
				course = Course.find_by_course_number(course_number)
				course = Course.create(:course_number => course_number) if course.nil?
				spec = course.course_specializations.build(:spec_course_type => ct, :optional => optional)
				course.save
			end
		end
		
		# Setting 26027 as Naturvidenskabelig grundfag
		basic_course_numbers = [26027, 26000]
		basic_course_numbers.each do |cn|
			course = Course.find_by_course_number(cn)
			math1 = Course.find_by_course_number(1005)
			basic_spec_course_types_all = math1.course_specializations.map(&:spec_course_type) if not math1.nil?
			if not basic_spec_course_types_all.empty? and not course.nil?
				basic_spec_course_types_all.each do |ct|
					course.course_specializations.build(:spec_course_type => ct)
				end
				course.save
			end
		end
		
		# Setting semester span (if the semester lasts more than one semester)
		courses_with_span = { 1005 => 2, 10020 => 2, 10022 => 2 }
		courses_with_span.each do |c, span|
			Course.find_by_course_number(c).semester_span = span
		end
  end
  
  task :teachers => :environment do
    require 'mechanize'
    agent = Mechanize.new
    puts "Teachers: #{Teacher.all.count}"
    Teacher.all.each do |t|
      info_url = "http://www.dtu.dk/Service/Telefonbog.aspx?id=#{t.dtu_teacher_id}&type=person&lg=showcommon"
      page = agent.get("#{info_url}")
      print "#{t.name} - #{t.dtu_teacher_id}"
      phone_text = page.search("div:nth-child(9) div:nth-child(2)").text
      if !%r{\d{8}}.match(phone_text)
        puts "Phone-error on #{t.name} - #{t.dtu_teacher_id}:    #{phone_text}"
      else
        puts "#{t.name} - #{t.dtu_teacher_id} - #{phone_text}"
      end
      #puts "- #{building} - #{room} - #{phone_text}"
    end    
  end
end