class CreateStudyplanItems < ActiveRecord::Migration
  def change
    create_table :studyplan_items do |t|
      t.references :student
      t.references :course
      t.references :schedule
      t.integer :semester

      t.timestamps
    end
    add_index :studyplan_items, :student_id
    add_index :studyplan_items, :course_id
    add_index :studyplan_items, :schedule_id
  end
end
