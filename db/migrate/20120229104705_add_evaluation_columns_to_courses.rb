class AddEvaluationColumnsToCourses < ActiveRecord::Migration
  def up
    add_column :courses, :exam_schedule, :string
    add_column :courses, :exam_form, :string
    add_column :courses, :exam_duration, :time
    add_column :courses, :exam_aid, :string
    add_column :courses, :evaluation_form, :string
    
    drop_table :evaluations
  end
  
  def down
    remove_column :courses, :exam_schedule
    remove_column :courses, :exam_form
    remove_column :courses, :exam_duration
    remove_column :courses, :exam_aid
    remove_column :courses, :evaluation_form
    
    create_table :evaluations do |t|
      t.references :course
      t.string :exam_schedule
      t.string :exam_form
      t.time :exam_duration
      t.string :exam_aid
      t.string :evaluation_form

      t.timestamps
    end
    add_index :evaluations, :course_id
  end
  
  
end