# encoding: utf-8
desc "Import courses from kurser.dtu.dk"
task :scrape_courses, [:seed] => :environment do |t,args|
  args.with_defaults(:seed => 'false')
  if args.seed == 'true' || args.seed == 1
    db_seed = 1 # db_seed = true for seeding database with scraping content (debug needs to be false)
  end
  
  language  = :en        # :da or :en (for danish or english)
  debug     = !db_seed   # debug = true for print in console
  check_db_types = true  # true if the scraper should check data-types

  require 'mechanize'
  agent = Mechanize.new   
  
  # Reset database if seeding
  if !debug & db_seed
    Rake::Task['db:reset'].invoke
  end 
  
  # URL's for different searches on kurser.dtu.dk
  url = "http://www.kurser.dtu.dk/"
  url_civil = "http://www.kurser.dtu.dk/search.aspx?lstType=DTU_MSC%C2%A4&YearGroup=2011-2012&btnSearch=Search"
  url_software = "http://www.kurser.dtu.dk/search.aspx?lstTeachingPeriod=E1;E2;E3;E4;E5;E1A;E2A;E3A;E4A;E5A;E1B;E2B;E3B;E4B;E5B;E&lstType=Teknologisk%20linjefag,%20Softwareteknologi&YearGroup=2011-2012&btnSearch=Search"
  url_test2 = "http://www.kurser.dtu.dk/search.aspx?lstType=DTU_FOOD_SCI%C2%A4&YearGroup=2011-2012&btnSearch=Search"
  
  # Fetching the URL
  #page = agent.get(url_software)
  #page = agent.get(url_test2)
  page = agent.get(url_civil)
  
  # Amount of courses in different searches
  course_amount = 893
  procent_ind = 0
  
  # Saving each link of the course in the array
  array = []
  agent.page.links_with(:href => %r{\d{5}\.aspx\?menulanguage=.*}).each do |link|
    link_url = link.href.to_s
    link_url = link_url.gsub("da","en") if language == :en
    array << link_url unless array.include?(link_url)
  end
  
  # Error hash used for checking data-types
  error = {}
  
  # Taking each link and scraping
  array.each_with_index do |e, i|    
    current_course = {}
    current_course_teachers = []
    current_course_types_head = []
    current_course_types = []
    current_course_keywords = []
    current_course_evaluation = {}
    current_course_institute = {}
        
    other_info = {}
    page = agent.get("#{url}#{e}")
    top_comment = ''
    
    # The table with content
    table = page.search("div.CourseViewer table")[1]
    table_rows = table.search("tr")
    
      # First row (title and course number)
      row1 = table_rows[0]
        
        # Title
        title = row1.search("h2").text
        current_course[:title] = %r{^\d{5}.(.+)}.match(title)[1].to_s
        current_course[:course_number] = %r{^\d{5}}.match(title).to_s.to_i
      
      # Top comment (only existing if comment written)
      # Observed: 
      #   if the css selector below is used the course page will give
      #   exactly 2 results (array with length 2). else the length is
      #   3 or more. maybe not for all?
      if table.search("tr:nth-child(2) .normal").length == 2
        current_course[:top_comment] = table_rows[2].search("p").text
      end      
    
      # Content 
      content_table = page.search("div.CourseViewer table")[3]
      
        # Content table rows    
        content_rows = content_table.search("tr")
        
          # Title på et andet sprog (row 1)
          other_info[:title_other_language] = content_rows[1].search("td")[1].text.strip.chomp
          
          # Sprog (row 2)
          current_course[:language] = content_rows[2].search("td")[1].text.strip.chomp
          
          # ECTS points (row 3)
          current_course[:ects_points] = content_rows[3].search("td")[1].text.strip.chomp
          
          # Course types (row 5)
          # Her angives, om det er Civil, Diplom, Levnedsmiddel, Ph.d. etc.
          # Hvordan skal det struktureres i databasen?
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
          course_attributes = { :da => {
                                        :mandatory => {
                                                      :schedule => "Skemaplacering:",
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
                                                      :prereq_obl => "Obligatoriske forudsætninger:",
                                                      :prereq_qua => "Faglige forudsætninger:",
                                                      :prereq_opt => "Ønskelige forudsætninger:"
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
                                                      }
                                                      
                                        
                                },
                                :en => {
                                        :mandatory => {
                                                      :schedule => "Schedule:",
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
                                                      :prereq_obl => "Mandatory Prerequisites:",
                                                      :prereq_qua => "Qualified Prerequisites:",
                                                      :prereq_opt => "Optional Prerequisites:"
                                                      },
                                        :institute => {
                                                      :institute => "Department:",
                                                      },
                                        :text_att => {
                                                      :course_objectives => "General course objectives:",
                                                      :content => "Content:",
                                                      :litteratur => "Litteratur:",
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
                                                      :keywords => "Nøgleord:"
                                                      }
                                        
                                        
                                        }
                                
                               }
          
          # Relations to the course
            current_course_evaluation[:course_id] = current_course[:course_number]
          # Relations end
          
          content_rows.each_with_index do |row, row_i|
            att_column = row.search("td")
            att_title = att_column[0].text.chomp.strip
            
            # Mandatory attributes
            course_attributes[language][:mandatory].each do |key, att|
              if att_title == att
                current_course[key] = att_column[1].text.strip.chomp
              end
            end
            
            # Evaluation attributes
            course_attributes[language][:evaluation].each do |key, att|
              if att_title == att
                current_course[key] = att_column[1].text.chomp.strip
              end
            end
            
            # # Prerequisites
            # course_attributes[language][:prerequisites].each do |key, att|
            #   if att_title == att
            #     # Do something about the prerequisites
            #   end
            # end
            
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
                  objective_list.each do |o|
                    objectives << o.text.chomp.strip unless objectives.include?(o.text.chomp.strip)
                  end
                  current_course[key] = objectives
              end
            end
            
            # The responsible teachers
            course_attributes[language][:responsible].each do |key, att|
              if att_title == att
                content_rows[row_i + 1].search("td a.menulink").each do |link|
                  if !%r(mailto:.*).match(link[:href])
                    t_id = %r(http:\/\/www.dtu.dk\/Service\/Telefonbog\.aspx\?id=(.*)&type=person&lg=showcommon).match(link[:href].chomp.strip)[1]
                    t_name = link.text.chomp.strip
                    current_course_teachers << { :name => t_name, :dtu_teacher_id => t_id }
                  end
                end
              end
            end
            
            # Website / Homepage / Hjemmeside ...
            course_attributes[language][:homepage].each do |key, att|
              if att_title == att
                homepage = att_column[1].search("a").text.chomp.strip
                current_course[key] = homepage.strip
              end
            end 
            
            # Keywords
            course_attributes[language][:keywords].each do |key, att|
              if att_title == att
                current_course_keywords << att_column[1].text.chomp.strip
              end
            end
              
          end 
          
    # Testing data types
    not_string_att = [:course_number, :exam_duration, :ects_points, :open_education, :course_objectives, 
                      :learn_objectives, :content,:institute_id, :remarks, :top_comment, :teaching_form, :exam_form ]
    if check_db_types
      current_course.each do |key, att|
        if !not_string_att.include?(key)
          error[key] = att if att.length > 255 && !error[key]
        end
      end
    end
    
    # Printing debug data
    if debug      
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
    
    if !debug && db_seed
      # Adding institute
      current_course[:institute_id] = Institute.find_or_create_by_dtu_institute_id(current_course_institute)
      created_course = Course.create(current_course)
      
      # Adding teachers
      current_course_teachers.each do |t|
        created_course.teachers << Teacher.find_or_create_by_dtu_teacher_id(t)
      end
      
      # Adding keywords
      current_course_keywords.each do |k|
        created_course.keywords << Keyword.find_or_create_by_keyword(k)
      end
      
      # Adding head course-types (civil, diplom osv.)
      current_course_types_head.each do |cth|
        created_course.course_types << CourseType.find_or_create_by_title(cth, :course_type_type => 1)
      end
      
      # Adding special course-types (teknologisk specialisering osv.)
      current_course_types.each do |ct|
        created_course.course_types << CourseType.find_or_create_by_title(ct, :course_type_type => 2)
      end
      
      # Saving course
      created_course.save
      
      # Some display for the console
      
      #cn_display = current_course[:course_number]
      #cn_display = "0#{cn_display}" if current_course[:course_number] < 10000   
      #puts "Added to the database: #{cn_display} #{current_course[:title]} "
    end
    
    if db_seed || check_db_types
      print "|" if i == 0
      if i == course_amount - 1
        puts "|"
      elsif Integer(Float(i) % (Float(course_amount) / 100)) == 0
        print "="
        procent_ind = procent_ind + 1
        print "#{procent_ind}%" if procent_ind % 10 == 0
      end
      #puts index/course_amount_f * 100
    end
    
    # Process view
  end
  if check_db_types
    error.each do |key, e|
      puts "DATA-TYPE for attribute #{key} is too long to be a string\nExample: #{e}"
    end 
  end 
end