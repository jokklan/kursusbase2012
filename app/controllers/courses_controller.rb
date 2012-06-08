class CoursesController < ApplicationController
  def index
    if params[:search]
      @courses = Course.search_params(params[:search])
    elsif current_student.present?
			@courses = current_student.course_recommendations.select { |c| c.course.active? and current_student.should_be_recommended(c.course) }[0,20]
		else
		  redirect_to root_path and return
		end
    
    if @courses.count == 1
      redirect_to @courses.first
    end
  end

  def show
    @course = Course.find_by_course_number(params[:id])
    raise ActionController::RoutingError.new('Course not found') if @course.nil? || !@course.active?
		@studyplan_item = StudyplanItem.find_by_student_id_and_course_id(current_student.id, @course.id) if current_student.present?
    @blocked_courses = CourseRelation.where(:related_course_id => @course.id, :related_course_type => "Blocked")
  end

end
