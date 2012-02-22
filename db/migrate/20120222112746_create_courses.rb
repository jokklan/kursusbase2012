class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.integer :course_number
      t.string :title
      t.string :language
      t.float :ects_points
      t.boolean :open_education
      t.string :schedule
      t.string :teaching_form
      t.string :duration
      t.string :participant_limit
      t.text :course_objectives
      t.text :learn_objectives
      t.text :content
      t.string :litteratur
      t.string :institute
      t.string :registration
      t.string :homepage

      t.timestamps
    end
  end
end
