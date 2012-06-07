class AddSemesterSpanToCourses < ActiveRecord::Migration
  def change
		change_table :courses do |t|
			t.integer :semester_span, :default => 1
		end
  end
end
