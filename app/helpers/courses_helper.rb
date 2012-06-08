module CoursesHelper
  def schedule_table_cell(sch)
    puts "Schedule: #{sch}"
    schs = @course.schedules.select {|s| s.block[1,2] == sch}
    if schs.map {|s| s.block[0]}.include?("F") && schs.map {|s| s.block[0]}.include?("E")
      css_class = "allyear"
    elsif schs.map {|s| s.block[0]}.include?("F")
      css_class = "spring"
    elsif schs.map {|s| s.block[0]}.include?("E")
      css_class = "autumn"
    end
    if css_class.blank?
      "<td>#{sch}</td>".html_safe
    else
      "<td class=\"#{css_class}\"><strong>#{sch}</strong></td>".html_safe
    end
  end
  
  def season_text()
    if @course.schedules.map {|s| s.block[0]}.include?("F") && @course.schedules.map {|s| s.block[0]}.include?("E")
      I18n.translate('seasons.spring') + " " + I18n.translate('and') + " " + I18n.translate('seasons.autumn')
    elsif @course.schedules.map {|s| s.block[0]}.include?("F")
      I18n.translate('seasons.spring')
    elsif @course.schedules.map {|s| s.block[0]}.include?("E")
      I18n.translate('seasons.autumn')
    end
  end

	def display_course_list(courses)
		courses.sort_by! { |course| course.course_no.to_i }
		active_courses   = courses.select{|c| c.active?}
		inactive_courses = courses.select{|c| !c.active?}
		out = ""
		
		if !active_courses.empty?
			out += "<ul>"
			active_courses.each	do |course|
				out += "<li>" + (link_to "#{course.course_no} #{course.title}", course) + "</li>"
			end
			out += "</ul>"
		end
		if !inactive_courses.empty?
			out += "<div>"
			if !active_courses.empty?
				out += t('additionally') + ': '
			end
			inactive_courses.each do |course|
				out += course.course_no.to_s
				out += ', ' if course != inactive_courses.last
			end
			out += "</div>"
		end
		out.html_safe
	end
end
