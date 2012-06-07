class CreateStudyplans < ActiveRecord::Migration
  def change
		create_table :studyplans do |t|
			t.references :student
			t.integer :semester
			
			t.timestamp
		end
		add_index :studyplans, :student_id
  end
end
