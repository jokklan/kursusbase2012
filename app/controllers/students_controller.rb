class StudentsController < ApplicationController
	def show
		@student = Student.find(params[:id])
	end
	
	def index
		@students = Student.all
	end
	
	def new
		@student = Student.new
	end
	
	def create
		@student = Student.create(params[:student])
		
		redirect_to @student
	end
end
