class CreateStudentData < ActiveRecord::Migration
  def change
    create_table :student_data do |t|
      t.string :student_id
      t.references :field_of_study
      t.date :start_date

      t.timestamps
    end
    add_index :student_data, :field_of_study_id
  end
end
