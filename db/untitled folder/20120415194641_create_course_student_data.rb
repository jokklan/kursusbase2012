class CreateCourseStudentData < ActiveRecord::Migration
  def change
    create_table :course_student_data do |t|
      t.references :course
      t.references :student_data
      t.string :semester

      t.timestamps
    end
    add_index :course_student_data, :course_id
    add_index :course_student_data, :student_data_id
  end
end
