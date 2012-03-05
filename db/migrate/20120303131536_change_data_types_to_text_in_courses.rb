class ChangeDataTypesToTextInCourses < ActiveRecord::Migration
  def up
    change_table :courses do |t|
      t.change :remarks, :text, :limit => nil
      t.change :top_comment, :text, :limit => nil
      t.change :teaching_form, :text, :limit => nil
      t.change :exam_form, :text, :limit => nil
      t.change :exam_schedule, :text, :limit => nil
      t.change :schedule, :text, :limit => nil
      t.change :litteratur, :text, :limit => nil
      t.change :exam_duration, :string
    end
  end

  def down
    change_table :courses do |t|
      t.change :remarks, :string
      t.change :top_comment, :string
      t.change :teaching_form, :string
      t.change :exam_form, :string
      t.change :exam_schedule, :string
      t.change :schedule, :string
      t.change :litteratur, :string
      t.change :exam_duration, :time
    end
  end
end
