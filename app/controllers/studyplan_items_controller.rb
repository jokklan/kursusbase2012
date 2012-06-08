class StudyplanItemsController < ApplicationController
	def show
		@student = current_student
		if @student.present?
		
    	@course_basket = @student.studyplan_items.where(:semester => nil)
    	@semester = params[:semester].to_i

    	@max_semester = @student.current_semester + ((Student::TOTAL_ECTS_GOAL - @student.total_points) / (Student::TOTAL_ECTS_GOAL / 6)).ceil 
      params[:semester] = nil if (params[:semester] and (@semester < 0 or @semester > @max_semester))
			
			@studyplans = []
			semesters = params[:semester] ? 1 : @max_semester
			semesters.times do |i|
				semester = semesters > 1 ? @max_semester - i : @semester
  			if semester <= @student.current_semester.to_i
  				@studyplans << @student.find_course_students_by_semester(semester)
  			else
  				@studyplans << @student.find_studyplan_courses_by_semester(semester)
  			end
			end
  	else
  	  redirect_to login_path
	  end
	end
	
	def destroy
		@studyplan_item = StudyplanItem.find(params[:id])
		course = @studyplan_item.course
		@studyplan_item.destroy
		redirect_to studyplan_items_path, notice: "#{course.title} has been removed from your kursuskurv"
	end
	
	def create
		# Student
		@student = current_student
		
		# Finding course
		if params[:studyplan_item]
			@course = Course.find(params[:studyplan_item][:course_id])
			@studyplan_item = params[:studyplan_item]
		elsif params[:search]
			@course = Course.search_params(params[:search]).select { |c| not @student.has_planned_or_participated_in(c) }.first
			@studyplan_item = { :course_id => @course.id, :student_id => @student.id } if not @course.nil?
		end
		
		if not @course.nil?
			redirection = params[:studyplan_item] ? @course : studyplan_item_path
			if not @student.has_planned_or_participated_in(@course)
				@student.studyplan_items.build(@studyplan_item)
				if @student.save
					redirect_to redirection, alert: "The course has succesfully been added to your course basket"
				else
					redirect_to redirection, alert: "error occured trying to add to studyplan"
				end
			else
				redirect_to redirection, alert: "You have already planned or participated in the given course"
			end
		else
			redirect_to studyplan_item_path, notice: 'No course were found'
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
