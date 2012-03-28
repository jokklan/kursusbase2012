class AddPrerequisiteStringsToCourses < ActiveRecord::Migration
  def change
		add_column :courses, :point_block, :string
		add_column :courses, :qualified_prereq, :string
		add_column :courses, :optional_prereq, :string
		add_column :courses, :mandatory_prereq, :string
  end
end
