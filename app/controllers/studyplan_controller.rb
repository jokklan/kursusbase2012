class StudyplanController < ApplicationController
	def show
		@student = current_student
		redirect_to root_path if @student.nil?
		if params[:semester]
			if params[:semester].to_i <= @student.current_semester.to_i
				@studyplans = [ @student.find_courses_by_semester(params[:semester]) ]
			else
				@studyplans = [ @student.find_studyplan_by_semester(params[:semester]) ]
			end
		else
			@studyplans = []
			max_studyplan_semester = current_student.studyplan_items.maximum("semester")
			max_studyplan_semester.times do |i|
				semester = max_studyplan_semester - i
				if semester <= @student.current_semester.to_i
					@studyplans << @student.find_courses_by_semester(semester)
				else
					@studyplans << @student.find_studyplan_courses_by_semester(semester)
				end
			end
		end
	end
end
