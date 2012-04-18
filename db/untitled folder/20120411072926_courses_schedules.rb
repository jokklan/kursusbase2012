class CoursesSchedules < ActiveRecord::Migration
  def change
		create_table :courses_schedules do |t|
      t.integer :schedule_id
      t.integer :course_id
    end
  end
end
