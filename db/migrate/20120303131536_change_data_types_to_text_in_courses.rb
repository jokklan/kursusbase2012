class ChangeDataTypesToTextInCourses < ActiveRecord::Migration
  def up
    change_table :courses do |t|
      t.change :remarks, :text
      t.change :top_comment, :text
      t.change :teaching_form, :text
      t.change :exam_form, :text
      t.change :exam_duration, :string
    end
  end

  def down
    change_table :courses do |t|
      t.change :remarks, :string
      t.change :top_comment, :string
      t.change :teaching_form, :string
      t.change :exam_form, :string
      t.change :exam_duration, :time
    end
  end
end
