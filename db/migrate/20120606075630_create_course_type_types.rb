class CreateCourseTypeTypes < ActiveRecord::Migration
  def change
    create_table :course_type_types do |t|

      t.timestamps
    end

		CourseTypeType.create_translation_table!({
      :title => :string
    })
  end
end
