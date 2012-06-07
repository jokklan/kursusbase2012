class CreateStudyplanItems < ActiveRecord::Migration
  def change
		create_table :studyplan_items do |t|
			t.references :studyplan
			t.references :course
			
			t.timestamp
		end
		add_index :studyplan_items, :studyplan_id
		add_index :studyplan_items, :course_id
		
		create_table :schedules_studyplan_items do |t|
			t.references :schedule
			t.references :studyplan_item
		end
		add_index :schedules_studyplan_items, :schedule_id
		add_index :schedules_studyplan_items, :studyplan_item_id
  end
end
