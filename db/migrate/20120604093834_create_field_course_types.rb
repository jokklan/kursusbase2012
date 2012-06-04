class CreateFieldCourseTypes < ActiveRecord::Migration
  def change
    create_table :field_course_types do |t|
      t.references :field_of_study
      t.references :course_type

      t.timestamps
    end
    add_index :field_course_types, :field_of_study_id
    add_index :field_course_types, :course_type_id
  end
end
