desc "Import courses from kurser.dtu.dk"
task :scrape_courses => :environment do
  require 'mechanize'
  agent = Mechanize.new
  debug = true
  
  url = "http://www.kurser.dtu.dk/"
  url_civil = "http://www.kurser.dtu.dk/search.aspx?lstType=DTU_MSC%C2%A4&YearGroup=2011-2012&btnSearch=Search"
  url_software = "http://www.kurser.dtu.dk/search.aspx?lstTeachingPeriod=E1;E2;E3;E4;E5;E1A;E2A;E3A;E4A;E5A;E1B;E2B;E3B;E4B;E5B;E&lstType=Teknologisk%20linjefag,%20Softwareteknologi&YearGroup=2011-2012&btnSearch=Search"
  page = agent.get(url_software)
  
  #course = page.search("div.CourseViewer")[2]
  
  #html#ctl00_Html1 body form#aspnetForm div table tbody tr.ContentMain td.ContentMain span#ctl00_PlaceHolderMain_PageHtml div.CourseViewer div div table tbody tr td table tbody tr td table
  
  # Saving each link of the course in the array
  array = []
  agent.page.links_with(:href => %r{\d{5}\.aspx\?menulanguage=..}).each do |link|
    array << link.href unless array.include?(link.href)
  end  
  #puts array
  courses_info = {}
  
  

  # Taking each 
  array.each do |e|
    current_course = {}
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
      
      # Top comment (only existing if comment written)
      # Obersed: 
      #   if the css selector below is used the course page will give
      #   exactly 2 results (array with length 2). else the length is
      #   3 or more. maybe not for all?
      
      comment_check = table.search("tr:nth-child(2) .normal")
      
      if comment_check.length == 2
        top_comment = table_rows[2].search("p").text
        puts "Top comment:\n#{top_comment}" if debug
      end      
    
      # Content 
      content_table = page.search("div.CourseViewer table")[3]
      
        # Content table rows    
        content_rows = content_table.search("tr")
        index_corrector = 0
        
          # Row 1 - Title on another language
          title_other_language = content_rows[0].search("td")[1].text.strip.chomp
          
          # Row 2 - sprog
          current_course[:language] = content_rows[1].search("td")[1].text.strip.chomp
          
          # Row 3 - point
          current_course[:ects_points] = content_rows[2].search("td")[1].text.strip.chomp
          
          # Row 4 - blank
          
          # Row 5 - kursustype
          # WHAT TO DO HERE?
          
          # Introduces [*][+], where:
          # * index if not tought under open university
          # + index if tought under open university
          
          # Row [ ][5] - Under åben universitet
          # If the course is 'Taught under open university' a row for that is made
          # it has the unique css selector: '.value td.value', so this is used for indicator.
          # The index_corrector is increased if the course is has the above attribute
          if !(content_table.search(".value td.value").text[0..5] == "Kurset")
            index_corrector = index_corrector + 1
          end
          
          # Row [6][7] - Mere kursustype (eller tom)
          # AND HERE?
          
          # Row [7][8] - Linje - skip
          
          # Row [8][9] - Skema
          current_course[:schedule] = content_rows[9-index_corrector].search("td")[1].text.strip.chomp
          
          # Row [9][10] - Undervisningsform
          current_course[:teaching_form] = content_rows[10-index_corrector].search("td")[1].text.strip.chomp
          
          # Row [10][11] - Varighed
          current_course[:duration] = content_rows[11-index_corrector].search("td")[1].text.strip.chomp
          
          # Row [11][12] - Eksamensplacering - optional row
          current_course[:schedule]
          
          # Row 11 - evalueringsform
          # Row 12 - eksamensvarighed
          # Row 13 - hjælpemidler
          # Row 14 - bedømmelsesform
          # Row 15 - tidligere kursus
    
    # DEBUG
    if debug
      puts "###################################"
      puts "Title: #{current_course[:title]}"
      puts "English title: #{title_other_language}" if debug
      puts "Language: #{current_course[:language]}"
      puts "ECTS: #{current_course[:ects_points]}"
      puts "Schedule: #{current_course[:schedule]}"
      puts "Teaching form: #{current_course[:teaching_form]}"
      puts "Duration: #{current_course[:duration]}"
      
      
      puts "###################################"
    end
    # DEBUG end
    
    courses_info[current_course[:course_number]] = current_course
  end
  
  #attr_accessible :course_number,:title, 
  #                :language, :ects_points, :open_education, 
  #                :schedule, :teaching_form, :duration, :participant_limit,
  #                :course_objectives, :learn_objectives, :content,
  #                :litteratur, :institute, :registration, :homepage
  
  
  
  
end