class CourseTypesController < ApplicationController
  def index
    @course_types = CourseType.all
  end

  def show
    @course_type = CourseType.find(params[:id])
  end

  def new
    @course_type = CourseType.new
  end

  def edit
    @course_type = CourseType.find(params[:id])
  end

  def create
    @course_type = CourseType.new(params[:course_type])
    if @course_type.save
      redirect_to @course_type, notice: 'CourseType was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @course_type = CourseType.find(params[:id])
    if @course_type.update_attributes(params[:course_type])
      redirect_to @course_type, notice: 'CourseType was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @course_type = CourseType.find(params[:id])
    @course_type.destroy
  end
end
