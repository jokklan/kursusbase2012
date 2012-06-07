class StudyplanItemsController < ApplicationController
	def create
		@studyplan_item = StudyplanItem.new(params[:studyplan_item])
		@studyplan_item.student = current_student
		@course = Course.find(params[:studyplan_item][:course_id])
		if @studyplan_item.save
			redirect_to @course
		else
			redirect_to @course, notice: "error occured trying to add to studyplan"
		end
	end
	
	def index
		
	end
end
