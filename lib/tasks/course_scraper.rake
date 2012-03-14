# encoding: utf-8
namespace :scrape do
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
    
    languages = [:en, :da]
    languages.each do |language|
      
      #puts "Current #{language}"
      I18n.locale = language
    
      debug          = !db_seed   # debug = true for print in console
      check_db_types = false      # true if the scraper should check data-types      
    
      # URL's for different searches on kurser.dtu.dk
      url_dtu = "http://www.kurser.dtu.dk/"
      url_civil = "http://www.kurser.dtu.dk/search.aspx?lstType=DTU_MSC%C2%A4&YearGroup=2011-2012&btnSearch=Search"
      url_software = "http://www.kurser.dtu.dk/search.aspx?lstTeachingPeriod=E1;E2;E3;E4;E5;E1A;E2A;E3A;E4A;E5A;E1B;E2B;E3B;E4B;E5B;E&lstType=Teknologisk%20linjefag,%20Softwareteknologi&YearGroup=2011-2012&btnSearch=Search"
      url_test2 = "http://www.kurser.dtu.dk/search.aspx?lstType=DTU_FOOD_SCI%C2%A4&YearGroup=2011-2012&btnSearch=Search"
    
      # Fetching the URL
      agent = Mechanize.new
      url = url_civil
      page = agent.get(url)
    
      # Saving each link of the course in the array
      array = []
      agent.page.links_with(:href => %r{\d{5}\.aspx\?menulanguage=.*}).each do |link|
        link_url = link.href.to_s
        link_url = link_url.gsub("en","da") if language == :da
        link_url = link_url.gsub("da","en") if language == :en
        array << link_url unless array.include?(link_url)
      end
    
      # Error hash used for checking data-types
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
        current_course = {}
        current_course_teachers = []
        current_course_types_head = []
        current_course_types = []
        current_course_keywords = []
        current_course_institute = {}
          
        other_info = {}
        page = agent.get("#{url_dtu}#{e}")
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
                                                    }
                                    
                                    
                                      }
                            
                             }
      
        # Taking each row in the nice tables of kurser.dtu.dk
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
        string_att = [:title, :language, :registration, :homepage, :duration, :participant_limit, :exam_duration, 
                      :exam_aid, :evaluation_form, :former_course]
        if check_db_types
          current_course.each do |key, att|
            if string_att.include?(key)
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
          created_institute = Institute.find_by_dtu_institute_id(current_course_institute[:dtu_institute_id])
          if created_institute.nil?
            created_institute = Institute.create(current_course_institute)
          else
            created_institute.update_attributes(current_course_institute)
            created_institute.save
          end
          
          current_course[:institute_id] = created_institute.id
          
          created_course = Course.find_by_course_number(current_course[:course_number])
          if created_course.nil?
            created_course = Course.create(current_course)
          else
            created_course.update_attributes(current_course)
            created_course.save
          end
        
          # Adding teachers
          current_course_teachers.each do |t|
            teacher = Teacher.find_or_create_by_dtu_teacher_id(t) 
            created_course.teachers << teacher unless created_course.teachers.include?(teacher)
          end
        
          # Adding keywords
          if language == :en
            current_course_keywords.each do |k|
              keyword = Keyword.find_by_title(k)
              keyword = Keyword.create(:title => k) if keyword.nil?
              created_course.keywords << keyword
            end
        
            # Adding head course-types (civil, diplom osv.)
            current_course_types_head.each do |cth|
              course_type = CourseType.find_by_title_and_course_type_type(cth, "Main")
              course_type = CourseType.create(:title => cth, :course_type_type => "Main") if course_type.nil? 
              created_course.main_course_types << course_type
            end
        
            # Adding special course-types (teknologisk specialisering osv.)
            current_course_types.each do |ct|
              course_type = CourseType.find_by_title_and_course_type_type(ct, "Spec")
              course_type = CourseType.create(:title => ct, :course_type_type => "Spec") if course_type.nil?
              created_course.spec_course_types << course_type
            end
          else
            created_course.keywords.with_translations(:en).each_index do |i|
              keyword = created_course.keywords[i]
              keyword.update_attributes(:title => current_course_keywords[i], :locale => language)
              keyword.save
            end
          
            created_course.main_course_types.with_translations(:en).where(:course_type_type => "Main").each_index do |i|
              course_type = created_course.main_course_types[i]
              course_type.update_attributes(:title => current_course_types_head[i], :locale => language)
              course_type.save
            end
          
            created_course.spec_course_types.with_translations(:en).where(:course_type_type => "Spec").each_index do |i|
              course_type = created_course.spec_course_types[i]
              course_type.update_attributes(:title => current_course_types[i], :locale => language)
              course_type.save
            end
          end
        
          # Saving course
          created_course.save
        end
      
        if db_seed || check_db_types
          print "|" if i == 0 || i == course_amount - 1
          if Integer(Float(i) % (Float(course_amount) / 100)) == 0
            print "="
            procent_ind = procent_ind + 1
            print "#{procent_ind}%" if procent_ind % 10 == 0
          end
        end
      end
    
      # Link loop end
      if check_db_types
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