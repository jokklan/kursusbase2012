class SessionsController < ApplicationController
  def new
  end

  def create
    student = Student.find_or_create_by_student_number(:student_number => params[:student_number], :password => params[:password])
    if student
      session[:student_id] = student.id
      redirect_to root_url, notice: "Logged in!"
    else
      flash.now.alert = "Email or password is invalid"
      render "new"
    end
  end

  def destroy
    session[:student_id] = nil
    redirect_to root_url, notice: "Logged out!"
  end
end
