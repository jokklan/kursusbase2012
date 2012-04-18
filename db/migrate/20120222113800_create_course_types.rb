class CreateCourseTypes < ActiveRecord::Migration
  def up
    create_table :course_types do |t|
      t.string :course_type_type

      t.timestamps
    end
    
    CourseType.create_translation_table!({
      :title => :string
    })
    
    create_table :course_types_courses do |t|
      t.integer :course_type_id
      t.integer :course_id
      
    end
    
    add_index :course_types_courses, :course_type_id
    add_index :course_types_courses, :course_id
    
  end
  
  def down
    drop_table :course_types
    drop_table :course_types_courses
    CourseType.drop_translation_table!
  end
end