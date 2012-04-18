class CreateStudentData < ActiveRecord::Migration
  def change
    create_table :student_data do |t|
      t.string :student_id
      t.references :field_of_study
      t.date :start_date

      t.timestamps
    end
    
    add_index :student_data, :field_of_study_id
    
    create_table :course_student_data do |t|
      t.references :course
      t.references :student_data
      t.string :semester
    end
    
    add_index :course_student_data, :course_id
    add_index :course_student_data, :student_data_id
  end
end
