class ChangeCourseRelations < ActiveRecord::Migration
  def up
    remove_column :course_relations, :req_course_no
    remove_column :course_relations, :prerequisite
    add_column    :course_relations, :group_no, :integer
  end

  def down
    add_column    :course_relations, :req_course_no, :integer
    add_column    :course_relations, :prerequisite, :string
    remove_column :course_relations, :group_no
  end
end
