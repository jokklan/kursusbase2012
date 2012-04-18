class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.string :block

      t.timestamps
    end
    
    create_table :courses_schedules do |t|
      t.integer :schedule_id
      t.integer :course_id
    end
    
    add_index :courses_schedules, :schedule_id
    add_index :courses_schedules, :course_id
  end
end
