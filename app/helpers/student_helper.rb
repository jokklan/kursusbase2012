module StudentHelper
	def student_schedule_table_cell(schedule, courses_input = @student.find_course_students_by_semester(@student.current_semester), semester_input = @student.current_semester)
		# Determine current semester season
	  semester = semester_input
    season   = semester % 2 == 0 ? 'F' : 'E'

    block = "#{season}#{schedule}"

    # Find a match
    schs = []
		return "".html_safe if courses_input.nil?
		is_course_students = courses_input.first.class.name == 'CourseStudent'
		
    courses_input.each do |course_i|
			course = is_course_students ? course_i.course  : course_i
			passed = is_course_students ? course_i.passed? : false
			if course.course_no == "01005"
				schedules = @student.field_of_study.math_schedules(semester)
			else
				schedules = course.schedules
			end
			#return "#{block} - #{course.title}" if schedules.first.block == "F2A" unless schedules.first.nil?
			schedules.each do |schedule|
				if schedule.block == block
					rowspan = ''
					html_class = 'course'
					if block == "#{season}5A" and schedules.include? Schedule.find_by_block("#{season}5B")
						rowspan = ' rowspan="2"' 
					elsif block == "#{season}5B" and schedules.include? Schedule.find_by_block("#{season}5A")
						return ''
					end
					html_class += get_course_class(course)
					html_class += " not-passed" if not passed
					return "<td class=\"#{html_class}\"#{rowspan}><a href=\"#{course_path(course)}\">#{course.course_no} <strong>#{course.title}</strong></a></td>".html_safe
				end
			end
    end

  	"<td class=\"empty\">#{schedule}</td>".html_safe  
	end
	
	def student_schedule_week_course(courses_input = @student.find_course_students_by_semester(@student.current_semester), semester_input = @student.current_semester)
		semester = semester_input
    block    = semester % 2 == 0 ? 'Juni' : 'Januar'

		return "".html_safe if courses_input.nil?
		is_course_students = courses_input.first.class.name == 'CourseStudent'
		
    courses_input.each do |course_i|
			course = is_course_students ? course_i.course  : course_i
			passed = is_course_students ? course_i.passed? : false 
			course.schedules.each do |c|
				if c.block == block
					html_class = "course#{get_course_class(course)}"
					html_class += " not-passed" if not passed
					return link_to "#{course.course_no} #{course.title}".html_safe, course, :class => "#{html_class}"
				end
			end
		end
		"".html_safe
	end
	
	def get_course_class(course)
		if not @student.field_of_study.nil?
			if course.is_basic_course(@student)
				return ' basic'
			elsif course.is_main_course(@student)
				return ' main'
			elsif course.is_project_course(@student)
				return ' project'
			end
		end
		''
	end
end
