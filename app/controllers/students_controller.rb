class StudentsController < ApplicationController
	def show
	  unless @student = current_student
	    redirect_to courses_path
    end
	end
end
