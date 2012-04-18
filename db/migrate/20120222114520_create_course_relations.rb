class CreateCourseRelations < ActiveRecord::Migration
  def change
    create_table :course_relations do |t|
      t.integer :course_id
      t.integer :related_course_id
      t.integer :group_no
      t.string :related_course_type

      t.timestamps
    end
    
    add_index :course_relations, :course_id
    add_index :course_relations, :related_course_id
  end
end