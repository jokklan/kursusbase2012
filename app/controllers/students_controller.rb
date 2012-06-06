class StudentsController < ApplicationController
	def show
	  if @student = current_student
      # @courses = @student.current_courses.map(&:schedules)
    else
	    @student = Student.new
	    render "/home/index", layout: "home"
    end
	end
	
end
