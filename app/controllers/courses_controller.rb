class CoursesController < ApplicationController
  def index
    if params[:search]
      @courses = Course.search_params(params[:search])
    elsif current_student.present?
			@courses = current_student.course_recommendations
		else
		  @courses = []
		end
    
    if @courses.count == 1
      redirect_to @courses.first
    end
  end

  def show
    @course = Course.find_by_course_number(params[:id])
		@studyplan_item = StudyplanItem.find_by_student_id_and_course_id(current_student.id, @course.id) if not current_student.nil?
    @blocked_courses = CourseRelation.where(:related_course_id => @course.id, :related_course_type => "Blocked")
  end

  # GET /courses/new
  # GET /courses/new.json
  def new
    @course = Course.new
    

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @course }
    end
  end

  # GET /courses/1/edit
  def edit
    @course = Course.find(params[:id])
  end

  # POST /courses
  # POST /courses.json
  def create
    @course = Course.new(params[:course])

    respond_to do |format|
      if @course.save
        format.html { redirect_to @course, notice: 'Course was successfully created.' }
        format.json { render json: @course, status: :created, location: @course }
      else
        format.html { render action: "new" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /courses/1
  # PUT /courses/1.json
  def update
    @course = Course.find(params[:id])

    respond_to do |format|
      if @course.update_attributes(params[:course])
        format.html { redirect_to @course, notice: 'Course was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.json
  def destroy
    @course = Course.find(params[:id])
    @course.destroy

    respond_to do |format|
      format.html { redirect_to courses_url }
      format.json { head :no_content }
    end
  end
end
