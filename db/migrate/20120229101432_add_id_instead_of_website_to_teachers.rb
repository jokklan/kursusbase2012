class AddIdInsteadOfWebsiteToTeachers < ActiveRecord::Migration
  def change
    add_column :teachers, :dtu_teacher_id, :integer
    remove_column :teachers, :website
  end
end
