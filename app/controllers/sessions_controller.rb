class SessionsController < ApplicationController
  def new
    if current_student
      redirect_to root_url, notice: "You are already logged in"
    else
      @student = Student.new
      flash[:return_url] = login_path
    end
  end

  def destroy
    session[:student_id] = nil
    redirect_to root_url, notice: "Logged out!"
  end
end
