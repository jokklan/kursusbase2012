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
    current_course_teachers = []
    current_course_types = []
    current_course_keywords = []
    current_course_evaluation = {}
    current_course_institute = ''
        
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
        
        
        puts "###################################\nTitle: #{current_course[:title]}"
      
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
          other_info[:title_other_language] = content_rows[0].search("td")[1].text.strip.chomp
          
          # Sprog (row 2)
          current_course[:language] = content_rows[1].search("td")[1].text.strip.chomp
          
          # ECTS points (row 3)
          current_course[:ects_points] = content_rows[2].search("td")[1].text.strip.chomp
          
          # Row 4 - blank
          
          # Course types (row 5)
          # WHAT TO DO HERE?
          
          # Under åben universitet
          # If the course is 'Taught under open university' a row for that is made
          # it has the unique css selector: '.value td.value', so this is used for indicator.
          if !(content_table.search(".value td.value").text[0..5] == "Kurset")
            current_course[:open_education] = true
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
                current_course_evaluation[key] = att_column[1].text.chomp.strip
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
                current_course_institute = att_column[1].text.chomp.strip
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
                    objectives << o.text.strip.chomp
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
                    current_course_teachers << { :name => t_name, :id => t_id }
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
          
          puts "Course attributes:"
          pp current_course
          puts "Evaluation attributes:"
          pp current_course_evaluation  
          puts "Teachers:"
          pp current_course_teachers
          puts "Institute:"
          pp current_course_institute   
          puts "Keywords"
          pp current_course_keywords
    
    # DEBUG
    puts "###################################"
    
    courses_info[current_course[:course_number]] = current_course
  end  
end