class AddFormerCourseToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :former_course, :string
  end
end
