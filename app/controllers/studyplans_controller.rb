class StudyplansController < ApplicationController
	def index
		@studyplans = current_student.study_plans		
	end
	
	def show
		@studyplan = StudyPlan.find(params[:id])
	end
	
	def new
		@studyplan = Studyplan.new
	end
	
	def create
		@studyplan = Studyplan.new(params[:studyplan])
		
		if @studyplan.save
			redirect_to student_path(current_student)
		else
			render action: "new", notice: "error occured trying to create studyplan"
		end
	end
end
