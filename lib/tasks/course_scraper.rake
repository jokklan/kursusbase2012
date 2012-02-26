# encoding: utf-8
desc "Import courses from kurser.dtu.dk"
task :scrape_courses => :environment do
  require 'mechanize'
  agent = Mechanize.new
  debug = false
  language = :da      
  
  url = "http://www.kurser.dtu.dk/"
  url_civil = "http://www.kurser.dtu.dk/search.aspx?lstType=DTU_MSC%C2%A4&YearGroup=2011-2012&btnSearch=Search"
  url_software = "http://www.kurser.dtu.dk/search.aspx?lstTeachingPeriod=E1;E2;E3;E4;E5;E1A;E2A;E3A;E4A;E5A;E1B;E2B;E3B;E4B;E5B;E&lstType=Teknologisk%20linjefag,%20Softwareteknologi&YearGroup=2011-2012&btnSearch=Search"
  page = agent.get(url_software)
  
  # Saving each link of the course in the array
  array = []
  agent.page.links_with(:href => %r{\d{5}\.aspx\?menulanguage=..}).each do |link|
    array << link.href unless array.include?(link.href)
  end
  courses_info = {}
  
  # Taking each 
  array.each do |e|
    current_course = {}
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
        current_course[:title] = %r{^\d{5}.(.+)}.match(title)[1]
        current_course[:course_number] = %r{^\d{5}}.match(title)
        
        puts "###################################\nTitle: #{current_course[:title]}" #if debug
      
      # Top comment (only existing if comment written)
      # Observed: 
      #   if the css selector below is used the course page will give
      #   exactly 2 results (array with length 2). else the length is
      #   3 or more. maybe not for all?
      if table.search("tr:nth-child(2) .normal").length == 2
        other_info[:top_comment] = table_rows[2].search("p").text
      end      
    
      # Content 
      content_table = page.search("div.CourseViewer table")[3]
      
        # Content table rows    
        content_rows = content_table.search("tr")
        
          # Title på et andet sprog (row 1)
          title_other_language = content_rows[0].search("td")[1].text.strip.chomp
          
          # Sprog (row 2)
          current_course[:language] = content_rows[1].search("td")[1].text.strip.chomp
          
          # ECTS points (row 3)
          current_course[:ects_points] = content_rows[2].search("td")[1].text.strip.chomp
          
          # Row 4 - blank
          
          # Kursustype (row 5)
          # WHAT TO DO HERE?
          
          # Under åben universitet
          # If the course is 'Taught under open university' a row for that is made
          # it has the unique css selector: '.value td.value', so this is used for indicator.
          if !(content_table.search(".value td.value").text[0..5] == "Kurset")
            current_course[:open_education] = true
          end
          
          # DEBUG
          if debug
            puts "English title: #{title_other_language}"
            puts "Language: #{current_course[:language]}"
            puts "ECTS: #{current_course[:ects_points]}"
          end
          # DEBUG end
          
          # Mere kursustype (eller tom)
          # AND HERE?
          
          # Linje - skip
          
          # Attributes:
          # Kursets varighed
        	# - Eksamensplacering
        	# Evalueringsform
        	# - Eksamens varighed
        	# Hjælpemidler
        	# Bedømmelsesform
        	# - Tidligere kursus
        	# - Pointspærring
        	# - Obligatoriske forudsætninger
        	# - Faglige forudsætninger
        	# - Ønskelige forudsætninger
        	# - Deltagerbegrænsning
        	
        	#attr_accessible :course_number,:title, 
          #                :language, :ects_points, :open_education, 
          #                :schedule, :teaching_form, :duration, :participant_limit,
          #                :course_objectives, :learn_objectives, :content,
          #                :litteratur, :institute, :registration, :homepage
        	
          course_attributes = { :da => {
                                        :schedule => "Skemaplacering:",
                                        :teaching_form => "Undervisningsform:",
                                        :duration => "Kursets varighed:",
                                        :participant_limit => "Deltagerbegrænsning:"
                                        }
                                
                               }
                               
          other_attributes = { :da => {
                                      :exam_schedule => "Eksamensplacering:",
                                      :exam_form => "Evalueringsform:",
                                      :exam_duration => "Eksamens varighed:",
                                      :aid => "Hjælpemidler:",
                                      :evaluation_form => "Bedømmelsesform:",
                                      :former_course => "Tidligere kursus:",
                                      :point_block => "Pointspærring:",
                                      :prereq_obl => "Obligatoriske forudsætninger:",
                                      :prereq_qua => "Faglige forudsætninger:",
                                      :prereq_opt => "Ønskelige forudsætninger:"
                                      }
                              } 
                              
          last_attributes = { :da => {
                                      :type1 => {
                                                :course_objectives => "Overordnede kursusmål:",
                                                :content => "Kursusindhold:",
                                                :litteratur => "Litteratur:",
                                                :remarks => "Bemærkninger:",
                                                },
                                      :type2 => {
                                                :learn_objectives => "Læringsmål:"
                                                },
                                      :type3 => {
                                                :responsible => "Kursusansvarlig:"
                                                },
                                      :type4 => {
                                                :institute => "Institut:",
                                                :homepage => "Kursushjemmeside:",
                                                :registration => "Tilmelding:"
                                                }
                                     }
                            }     

          content_rows.each_with_index do |row, row_i|
            att_column = row.search("td")
            att_title = att_column[0].text.strip.chomp
            course_attributes[language].each do |key, att|
              if att_title == att
                current_course[key] = att_column[1].text.strip.chomp
                puts "#{course_attributes[language][key]} #{current_course[key]}" if debug
              end
            end
            other_attributes[language].each do |key, att|
              if att_title == att
                other_info[key] = att_column[1].text.strip.chomp
                puts "#{other_attributes[language][key]} #{other_info[key]}" if debug
              end
            end
            last_attributes[language][:type1].each do |key, att|
              if att_title == att
                current_course[key] = content_rows[row_i + 1].search("td").text.strip.chomp
                puts "#{last_attributes[language][key]} #{current_course[key]}" if debug
              end
            end
            last_attributes[language][:type2].each do |key, att|
              
              if att_title == att
                #puts "#{att_title} == #{att}"
                objective_list = content_rows[row_i + 2].search("td ul li")
                objectives = []
                objective_list.each do |o|
                  objectives << o.text.strip.chomp
                end
              end
            end
            last_attributes[language][:type3].each do |key, att|
              if att_title == att
                content_rows[row_i + 1].search("td a.menulink").each do |link|
                  #link.text if !%r(mailto:.*).match(link.href)
                end
              end
            end
            last_attributes[language][:type4].each do |key, att|
              # Something
            end
          end 
          
          # The rest of the info (from course objectives and down)
          #objective_table = content_table.search("table.SubTableLevel1")
          #pp objective_table
          
    
    # DEBUG
    puts "###################################" if debug
    
    #pp current_course
    #pp other_info
    
    courses_info[current_course[:course_number]] = current_course
  end  
end