module StudentHelper
	def student_schedule_table_cell(schedule, semester_input = @student.semester)
		# Determine current semester season
	    semester = semester_input
	    season   = semester % 2 == 0 ? 'F' : 'E'

	    block = "#{season}#{schedule}"

	    thecourse = nil

	    # Find a match
	    schs = []
	    @student.current_courses.each do |course|
				#schs.add s.schedules.select { |s| s.block == block }
				course.schedules.each do |schedule|
					if schedule.block == block
						course_class = get_course_class(course)
						return "<td#{course_class}><a href=\"#{course_path(course)}\">#{course.course_no} <strong>#{course.title}</strong></a></td>".html_safe
					end
				end
	    end

    	"<td class=\"empty\">#{schedule}</td>".html_safe
	end
	def get_course_class(course)
		if not @student.field_of_study.nil?
			if course.is_basic_course(@student)
				return ' class="course basic"'
			elsif course.is_main_course(@student)
				return ' class="course main"'
			elsif course.is_project_course(@student)
				return ' class="course project"'
			end
		end
		' class="course"'
	end
end
