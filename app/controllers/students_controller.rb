class StudentsController < ApplicationController
	def show
	  puts "student show"
	  if @student = current_student
      # @courses = @student.current_courses.map(&:schedules)
    else
	    @student = Student.new
	    render "/pages/home", layout: "home"
    end
	end
	
end
