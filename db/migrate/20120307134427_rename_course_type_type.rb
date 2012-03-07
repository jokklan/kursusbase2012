class RenameCourseTypeType < ActiveRecord::Migration
  def up
    change_table :course_types do |t|
      t.change :course_type_type, :string
    end
  end

  def down
    change_table :course_types do |t|
      t.change :course_type_type, :integer
    end
  end
end
