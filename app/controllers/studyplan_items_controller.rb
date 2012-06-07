class StudyplanItemsController < ApplicationController
	def show
		@student = current_student
		@semester = params[:semester].to_i
		max_studyplan_semester = current_student.studyplan_items.maximum("semester").nil? ? 0 : current_student.studyplan_items.maximum("semester")
		@max_semester = [max_studyplan_semester, @student.current_semester].max
		redirect_to root_path if @student.nil? or (params[:semester] and (@semester < 0 or @semester > @max_semester))
		if params[:semester]
			if @semester.to_i <= @student.current_semester.to_i
				@studyplans = [ @student.find_courses_by_semester(@semester) ]
			else
				@studyplans = [ @student.find_studyplan_courses_by_semester(@semester) ]
			end
		else
			@studyplans = []
			#@studyplan_debug = { :max_studyplan_semester => max_studyplan_semester}
			@max_semester.times do |i|
				semester = @max_semester - i
				if semester <= @student.current_semester.to_i
					@studyplans << @student.find_courses_by_semester(semester)
				else
					@studyplans << @student.find_studyplan_courses_by_semester(semester)
				end
			end
		end
		
	end
	
	def index
		
		
	end
	
	def create
		@student = current_student
		@student.studyplan_items.build(params[:studyplan_item])
		@course = Course.find(params[:studyplan_item][:course_id])
		if @student.save
			redirect_to @course
		else
			redirect_to @course, notice: "error occured trying to add to studyplan"
		end
	end
	
	def index
		
	end
end
