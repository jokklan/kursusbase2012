module StudyplanItemsHelper
	def ects_points_block_progress(points)
		points / (Student::TOTAL_ECTS_GOAL/4)
	end
	def ects_points_block_percentage(points)
		percentage = (self.ects_points_block_progress(points) * 100).round(2)
		if percentage > 100
			100
		else
			percentage
		end
	end
	
	def semester_select_options
		@max_semester.times.map {|i| "#{i + 1}. semester"}.push("All semesters")
	end
	
	def studyplan_select_options(course)
		studyplan_amount = (@max_semester - current_student.current_semester)
		all_possible = studyplan_amount.times.map {|i| ["#{current_student.current_semester + i + 1}. semester", "#{current_student.current_semester + i + 1}"] }
		all_possible.select {|i| course.has_schedule_on_semester(i[0].to_i) }
	end
end
