class SessionsController < ApplicationController
  def new
    if current_student
      redirect_to root_url, notice: "You are already logged in"
    else
      @student = Student.new
    end
  end

  def create
    @student = Student.find_or_initialize_by_student_number(params[:student])
    if @student.save && @student.authenticate(params[:password])
      session[:student_id] = @student.id
      @student.update_courses
      if @student.new_record?
        @student.update_attributes(@student.get_info.select{|k,v| [:firstname, :lastname, :email].include? k})
      end
      redirect_to root_url, notice: "Logged in!"
    else
      render "new"
    end
  end

  def destroy
    session[:student_id] = nil
    redirect_to root_url, notice: "Logged out!"
  end
end
