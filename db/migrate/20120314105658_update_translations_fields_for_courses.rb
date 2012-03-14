class UpdateTranslationsFieldsForCourses < ActiveRecord::Migration
  def up
    add_column :course_translations, :former_course, :string
    add_column :course_translations, :exam_form, :text
    add_column :course_translations, :exam_aid, :string
    add_column :course_translations, :evaluation_form, :string
    remove_column :course_translations, :homepage
    add_column :courses, :homepage, :string
    
  end

  def down
    remove_column :course_translations, :former_course
    remove_column :course_translations, :exam_form
    remove_column :course_translations, :exam_aid
    remove_column :course_translations, :evaluation_form
    add_column :course_translations, :homepage, :string
    remove_column :courses, :homepage
  end
end