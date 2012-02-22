class CreateJoinTables < ActiveRecord::Migration
  def change
    create_table :courses_keywords do |t|
      t.integer :keyword_id
      t.integer :course_id
    end
    
    create_table :courses_teachers do |t|
      t.integer :teacher_id
      t.integer :course_id
    end
    
    create_table :courses_course_types do |t|
      t.integer :course_type_id
      t.integer :course_id
    end
  end
end
