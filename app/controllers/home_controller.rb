class HomeController < ApplicationController
  layout "home"
  
  def index
    if current_student
      redirect_to show_student_path
    end
  end
  
end
