class CreateCourseRecommendations < ActiveRecord::Migration
  def change
    create_table :course_recommendations do |t|
      t.references :student
      t.references :course
      t.integer :priority_value

      t.timestamps
    end
    add_index :course_recommendations, :student_id
    add_index :course_recommendations, :course_id
  end
end
