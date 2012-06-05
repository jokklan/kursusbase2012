class StudentsController < ApplicationController
	def show
	  unless @student = current_student
	    render "/home/index", layout: "home"
    end
	end
end
