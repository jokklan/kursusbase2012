class CreateCoursePrerequisites < ActiveRecord::Migration
  def change
    create_table :course_prerequisites do |t|
      t.references :course
      t.references :req_course
      t.integer :req_course_no
      t.string :prerequisite
      t.string :req_course_type

      t.timestamps
    end
    add_index :course_prerequisites, :course_id
    add_index :course_prerequisites, :req_course_id
  end
end
