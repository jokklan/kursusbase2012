class RenameReqCoursesToRelatedCourseInCourseRelations < ActiveRecord::Migration
  def up
    rename_column :course_relations, :req_course_id, :related_course_id
    rename_column :course_relations, :req_course_type, :related_course_type
  end

  def down
    rename_column :course_relations, :related_course_id, :req_course_id
    rename_column :course_relations, :related_course_type, :req_course_type
  end
end
