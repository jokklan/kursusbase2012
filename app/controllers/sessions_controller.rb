class SessionsController < ApplicationController
  def new
    if current_student
      redirect_to root_url
    else
      @student = Student.new
    end
  end

  def create
    @student = Student.find_or_initialize_by_student_number(params[:student])
    if @student.save
      session[:student_id] = @student.id
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
