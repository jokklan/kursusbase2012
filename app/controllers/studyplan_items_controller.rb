class StudyplanItemsController < ApplicationController
	def show
		@student = current_student
		@course_basket = @student.studyplan_items.where(:semester => nil)
		@semester = params[:semester].to_i
		@max_semester = @student.current_semester + ((Student::TOTAL_ECTS_GOAL - @student.total_points) / (Student::TOTAL_ECTS_GOAL / 6)).ceil 
		redirect_to root_path if @student.nil? or (params[:semester] and (@semester < 0 or @semester > @max_semester))
		if params[:semester]
			if @semester.to_i <= @student.current_semester.to_i
				@studyplans = [ @student.find_courses_by_semester(@semester) ]
			else
				@studyplans = [ @student.find_studyplan_courses_by_semester(@semester) ]
			end
		else
			@studyplans = []
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
	
	def destroy
		@studyplan_item = StudyplanItem.find(params[:id])
		course = @studyplan_item.course
		@studyplan_item.destroy
		redirect_to studyplan_items_path, notice: "#{course.title} has been removed from your kursuskurv"
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
	
	def update
		@student = current_student
		@studyplan_item = StudyplanItem.find(params[:id])
		if @studyplan_item.update_attributes(params[:studyplan_item])
			redirect_to studyplan_items_path
		else
			redirect_to studyplan_items_path, notice: 'Failed to add course to your studyplan'
		end
	end
end
