class RenameCoursesCourseTypesJoinTable < ActiveRecord::Migration
  def up
    drop_table :courses_course_types
    create_table :course_types_courses do |t|
      t.integer :course_id
      t.integer :course_type_id
    end
  end

  def down
    drop_table :course_types_courses
    create_table :courses_course_types do |t|
      t.integer :course_type_id
      t.integer :course_id
    end
  end
end
