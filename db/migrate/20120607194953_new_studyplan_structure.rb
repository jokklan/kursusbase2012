class NewStudyplanStructure < ActiveRecord::Migration
  def up
		drop_table :studyplans
		drop_table :schedules_studyplan_items
		change_table :studyplan_items do |t|
			t.references :student
			t.integer :semester
			
			t.timestamp
		end
		add_index :studyplan_items, :student_id
  end

  def down
		create_table :studyplans do |t|
			t.references :student
			t.integer :semester
			
			t.timestamp
		end
		add_index :studyplans, :student_id
		
		create_table :schedules_studyplan_items do |t|
			t.references :schedule
			t.references :studyplan_item
		end
		add_index :schedules_studyplan_items, :schedule_id
		add_index :schedules_studyplan_items, :studyplan_item_id
  end
end
