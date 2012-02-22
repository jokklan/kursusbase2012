desc "Import courses from kurser.dtu.dk"
task :scrape_courses => :environment do
  require 'mechanize'
  agent = Mechanize.new
  
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

  
  array.each do |e|
    current_course = {}
    page = agent.get("#{url}#{e}")
    
    # Title and coursenumber
    table = page.search("div.CourseViewer table")[1]
    title = table.search("tr td h2").text
    current_course[:title] = %r{^\d{5}.(.+)}.match(title)[1]
    current_course[:course_number] = %r{^\d{5}}.match(title)
    
    # Language
    title = table.search("tr td p").text
    
    
    
    
    
    courses_info[current_course[:course_number]] = current_course
  end
  
  #attr_accessible :course_number,:title, 
  #                :language, :ects_points, :open_education, 
  #                :schedule, :teaching_form, :duration, :participant_limit,
  #                :course_objectives, :learn_objectives, :content,
  #                :litteratur, :institute, :registration, :homepage
  
  
  
  
end