class AddCourseTypeTypeToCourseTypes < ActiveRecord::Migration
  def change
    add_column :course_types, :course_type_type, :integer
  end
end
