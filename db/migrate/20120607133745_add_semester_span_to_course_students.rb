class AddSemesterSpanToCourseStudents < ActiveRecord::Migration
  def change
		change_table :course_students do |t|
			t.integer :semester_span
		end
  end
end
