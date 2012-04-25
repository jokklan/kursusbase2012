class RenameUserToStudent < ActiveRecord::Migration
  def change
    rename_table :users, :students
    rename_table :course_users, :course_students
    rename_column :course_students, :user_id, :student_id
  end
end
