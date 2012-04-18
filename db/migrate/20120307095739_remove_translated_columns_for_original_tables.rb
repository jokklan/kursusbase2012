class RemoveTranslatedColumnsForOriginalTables < ActiveRecord::Migration
  def up
    remove_column :course_types, :title
    remove_column :institutes, :title
    remove_column :keywords, :keyword
    remove_column :courses, :title
    remove_column :courses, :teaching_form
    remove_column :courses, :duration
    remove_column :courses, :participant_limit
    remove_column :courses, :registration
    remove_column :courses, :course_objectives
    remove_column :courses, :learn_objectives
    remove_column :courses, :content
    remove_column :courses, :litteratur
    remove_column :courses, :remarks
    remove_column :courses, :top_comment
    remove_column :courses, :former_course
    remove_column :courses, :exam_form
    remove_column :courses, :exam_aid
    remove_column :courses, :evaluation_form
  end

  def down
    add_column  :course_types, :title, :string
    add_column :institutes, :title, :string
    add_column :keywords, :keyword, :string
    add_column :courses, :title, :string
    add_column :courses, :teaching_form, :text
    add_column :courses, :duration, :string
    add_column :courses, :participant_limit, :string
    add_column :courses, :registration, :string
    add_column :courses, :course_objectives, :text
    add_column :courses, :learn_objectives, :text
    add_column :courses, :content, :text
    add_column :courses, :litteratur, :text
    add_column :courses, :remarks, :text
    add_column :courses, :top_comment, :text
    add_column :courses, :former_course, :string
    add_column :courses, :exam_form, :text
    add_column :courses, :exam_aid, :string
    add_column :courses, :evaluation_form, :string
  end
end