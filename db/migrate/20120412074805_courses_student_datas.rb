class CoursesStudentDatas < ActiveRecord::Migration
  def change
		create_table :courses_student_datas do |t|
      t.integer :course_id
      t.integer :student_data_id
    end
  end
end
