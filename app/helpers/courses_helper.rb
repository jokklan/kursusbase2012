# encoding: utf-8
module CoursesHelper
	# CONSTANTS
	# Days
	MONDAY    = 0
	TUESDAY   = 1
	WEDNESDAY = 2
	THURSDAY  = 3
	FRIDAY    = 4
	SATURDAY  = 5
	SUNDAY    = 6
	# Seasons
	SPRING    = 0
	AUTUMN    = 1
	JANUARY   = 2
	JUNE      = 3
	
	# Is it worth displaying the schedule table for a course?
	def has_schedule(course, schedule_details)
		# Does this course have schedule details belonging to either spring or autumn?
		has_sched_details = !schedule_details.empty? && 
				(schedule_details['is_spring'] || schedule_details['is_autumn'])
		sched = real_schedules(course)
		 
		if course.duration == "[Kurset følger ikke DTUs normale skemastruktur]" && !has_sched_details
			return false
		end
		if sched.empty? && !has_sched_details
			return false
		end
		if sched.count > 6
			return false
		end
		true
	end
	
	# Convert schedule code to day and time of day
	def convert_schedule_code(code)
		# Eliminate season
		lcode = code.downcase.gsub /^f|^e/, ""
		case lcode
			when '1a'
				[MONDAY, :top]
			when '2a'
				[MONDAY, :bottom]
			when '3a'
				[TUESDAY, :top]
			when '4a'
				[TUESDAY, :bottom]
			when '5a'
				[WEDNESDAY, :top]
			when '5b'
				[WEDNESDAY, :bottom]
			when '2b'
				[THURSDAY, :top]
			when '1b'
				[THURSDAY, :bottom]
			when '4b'
				[FRIDAY, :top]
			when '3b'
				[FRIDAY, :bottom]
			else
				[]
		end
	end
	
	# Count the amount of schedules in 13-week periods only
	def real_schedules(course)
		course.schedules.select{ |s| ["E", "F"].include? s.block[0] }
	end
	
	# Displaying a schedule table cell
	def schedule_table_cell(sch, schedule_details)
		# Defined schedules
		schs = @course.schedules.select {|s| s.block[1,2] == sch}
		
		# Time
		time = convert_schedule_code(sch)
		
		# Seasons
		is_spring = schs.map {|s| s.block[0]}.include? "F"
		is_autumn = schs.map {|s| s.block[0]}.include? "E"
		
		css_class = ""
		
		# Main cell
		has_main_cell = is_spring || is_autumn
		if is_spring && is_autumn
			css_class = "allyear"
		elsif is_spring
			css_class = "spring"
		elsif is_autumn
			css_class = "autumn"
		end
		
		# Cell title
		seasontitle = t("seasons.#{css_class}")
		title = t("days.day_#{time[0].to_s}") + 
			" " + t('times.' + (time[1] == :top ? 'beforenoon' : 'afternoon')) + ", #{seasontitle}"
			
		
		# HTML output
		cssout   = css_class.blank? ? "" : " class=\"#{css_class.strip}\""
		titleout = css_class.blank? ? "" : " title=\"#{title}\""
		if has_main_cell
			"<td#{titleout}#{cssout}><strong>#{sch}</strong></td>".html_safe
		else
			"<td#{titleout}#{cssout}>#{sch}</td>".html_safe
		end
	end
	
	def schedule_outer_cells(position, schedule_details)
		# Base variable
		out = ""
		# Only display this outer row if we have any unusual schedule lying here
		if !schedule_details.empty? && schedule_details['position'] == position && !schedule_details['days'].empty?
			# Season
			if schedule_details['is_spring'] && schedule_details['is_autumn']
				css_class = "allyear"
			elsif schedule_details['is_spring']
				css_class = "spring"
			elsif schedule_details['is_autumn']
				css_class = "autumn"
			end
			
			# Outer row HTML output
			out = '<tr class="outer">'
			for day in 0..4
				if schedule_details['days'].include? day
					out += "<td class=\"#{css_class}\"></td>"
				else
					out += "<td></td>"
				end
			end
			out += "</tr>"
		end
		out.html_safe
	end
	
	# Displaying the season
	def season_text(course, schedule_details)
		# First: Look at schedules to determine season text
		is_spring = course.schedules.map {|s| s.block[0]}.include?("F")
		is_autumn = course.schedules.map {|s| s.block[0]}.include?("E")
		
		if !is_spring && !is_autumn
			# Second: Try to look at the string to determine
			schedule  = course.schedule.downcase
			is_spring = !!schedule.match(/forår|spring/)
			is_autumn = !!schedule.match(/efterår|autumn|fall/)
			is_jan    = !!schedule.match(/january?/)
			is_june   = !!schedule.match(/jun(e|i)/)
		end
		
		# Spring or autumn
		if is_spring && is_autumn
			return t('seasons.spring') + " " + t('and') + " " + 
				t('seasons.autumn')
		elsif is_spring
			return t('seasons.spring')
		elsif is_autumn
			return t('seasons.autumn')
		elsif is_jan && is_june
			return t('months.jan') + " " + t('and') + " " + 
				t('months.jun')
		elsif is_jan
			return t('months.jan')
		elsif is_june
			return t('months.jun')
		end
	end
	
	# Convert 12h hour to 24h
	def hour_12h_to_24h(hour, am)
		if am == 'am'
			hour % 12
		else
			(hour % 12) + 12
		end
	end
	
	# Determine the details about an unusual course schedule
	def determine_unusual_schedule(course)
		if !course.schedules.empty?
			return {} # Not unusual at all
		end
		
		schedule      = course.schedule.downcase
		schedule_note = course.schedule_note.downcase
		
		# Seasons
		is_spring = !!schedule.match(/forår|spring/)
		is_autumn = !!schedule.match(/efterår|autumn|fall/)
		is_jan    = !!schedule.match(/january?/)
		is_june   = !!schedule.match(/jun(e|i)/)
		
		# Days
		days     = []
		dregexes = [/mandag|monday/, /tirsdag|tuesday/, /onsdag|wednesday/, /torsdag|thursday/, /fredag|friday/, /lørdag|saturday/, /søndag|sunday/]
		for day in 0..6
			if schedule_note.match(dregexes[day])
				days << day
			end
		end
		
		# Time of day
		datimeregex = /kl\.\s+([0-9]{1,2})/
		entimeregex = /([0-9]{1,2})\s*(am|pm)?\s*(-+\s*([0-9]{1,2})\s*(am|pm))?/
		
		datime = schedule_note.match(datimeregex)
		entime = schedule_note.match(entimeregex)
		
		before_day = false # Before ordinary day
		after_day  = false # After ordinary day
		hour       = nil
		position   = nil
		
		if datime
			# Danish time specification, always 24h
			hour = datime[1].to_i
		elsif entime
			# English time specification, might be 12h
			begin_hour = entime[1].to_i
			begin_am   = entime[2]
			end_hour   = entime[4].to_i
			end_am     = entime[5]
			
			if !begin_am.nil?
				begin_hour = hour_12h_to_24h(begin_hour, begin_am)
			end
			
			if !end_am.nil? && !end_hour.nil?
				end_hour = hour_12h_to_24h(end_hour, end_am)
				if begin_am.nil?
					begin_hour = hour_12h_to_24h(begin_hour, end_am)
				end
			end
			
			hour = begin_hour
		end
		
		if !hour.nil?
			if hour > 15
				before_day = false
				after_day  = true
				position   = :bottom
			end
			if hour < 8
				before_day = true
				after_day  = false
				position   = :top
			end
		end
		
		{
			'is_spring'  => is_spring,
			'is_autumn'  => is_autumn,
			'is_jan'     => is_jan,
			'is_june'    => is_june,
			'days'       => days,
			#'datime'     => datime[1]
			#'entime'     => [entime[1], entime[2], entime[4], entime[5]],
			'before_day' => before_day,
			'after_day'  => after_day,
			'position'   => position
		}
		#[is_spring, is_autumn, is_jan, is_june, days, entime.to_a, before_day, after_day]
	end
	
	# Display list of courses inside a course page (for prerequisites, etc.)
	def display_course_list(courses)
		# First, sort the courses by ascending course number
		courses.sort_by! { |course| course.course_no.to_i }
		
		# Split courses into active and inactive courses
		active_courses   = courses.select{|c| c.active?}
		inactive_courses = courses.select{|c| !c.active?}
		
		# Our output
		out = ""
		
		# List of active courses
		if !active_courses.empty?
			out += "<ul>"
			active_courses.each	do |course|
				out += "<li>" + (link_to "#{course.course_no} #{course.title}", course) + "</li>"
			end
			out += "</ul>"
		end
		
		# List of inactive courses
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
		
		# Output
		out.html_safe
	end
end
