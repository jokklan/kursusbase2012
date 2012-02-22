class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.references :course
      t.string :exam_schedule
      t.string :exam_form
      t.time :exam_duration
      t.string :exam_aid
      t.string :evaluation_form

      t.timestamps
    end
    add_index :evaluations, :course_id
  end
end
