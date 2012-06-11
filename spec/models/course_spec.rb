require 'spec_helper'

describe Course do
  before :each do
    @course = Course.create(:title => "test", :course_number => "12345")
  end
  
  describe "#find_schedules_by_semester" do
    it "finds all schedules for 4-th semester" do
      f2b = Schedule.create(:block => 'F2B')
      juni = Schedule.create(:block => 'Juni')
      e2b = Schedule.create(:block => 'E2B')
      
      @course.find_schedules_by_semester(4).should include(f2b, juni)
      @course.find_schedules_by_semester(4).should not_include(e2b)
    end
    
    descripe "#search_params" do
      it "returns a course if the course have the same titel as the search query" do
        Course.search_params("test").should include(@course)
      end
      
      it "filters after ects points if query contains ects:#" do
        course10 = Course.create(:title => "course 10", :course_number => "12345", :ects_points => 10)
        course15 = Course.create(:title => "course 15", :course_number => "12345", :ects_points => 15)
        Course.search_params("course").should include(course10, course15)
        Course.search_params("course ects:10").should include(course10)
        Course.search_params("course ects:10").should not_include(course10)
      end
    end
    
  end
  
end