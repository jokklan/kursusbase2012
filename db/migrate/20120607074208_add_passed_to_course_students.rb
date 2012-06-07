class AddPassedToCourseStudents < ActiveRecord::Migration
  def change
		change_table :course_students do |t|
			t.boolean :passed
		end
  end
end
