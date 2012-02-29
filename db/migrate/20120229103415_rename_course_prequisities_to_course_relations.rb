class RenameCoursePrequisitiesToCourseRelations < ActiveRecord::Migration
  def up
    rename_table :course_prerequisites, :course_relations
  end

  def down
    rename_table :course_relations, :course_prerequisites
  end
end
