class StudentsController < ApplicationController
	def show
	  unless @student = current_student
	    @student = Student.new
	    render "/home/index", layout: "home"
    end
	end
end
