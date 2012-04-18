class CreateCourseTypes < ActiveRecord::Migration
  def up
    create_table :course_types do |t|
      t.string :title
      t.string :course_type_type

      t.timestamps
    end
    
    CourseType.create_translation_table!({
      :title => :string
    }, {
      :migrate_data => true
    })
    
  end
  
  def down
  end
end