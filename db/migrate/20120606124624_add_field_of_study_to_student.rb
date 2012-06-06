class AddFieldOfStudyToStudent < ActiveRecord::Migration
  def change
		change_table :students do |t|
			t.references :field_of_study
		end
  end
end
