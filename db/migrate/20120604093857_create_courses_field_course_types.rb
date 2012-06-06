class CreateCoursesFieldCourseTypes < ActiveRecord::Migration
  def change
		create_table :courses_field_course_types do |t|
      t.references :course
      t.references :field_course_type
			t.string 		 :semester_recommended
			t.boolean 	 :optional
    end
		
		add_index :courses_field_course_types, :course_id
		add_index :courses_field_course_types, :field_course_type_id
  end
end
