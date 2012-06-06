class CreateCourses < ActiveRecord::Migration
  def up
    create_table :courses do |t|
      t.integer :course_number
      t.string :language
      t.float :ects_points
      t.boolean :open_education
			t.string :schedule
      t.integer :institute_id
      t.string :homepage
      t.text :exam_schedule
      t.string  :exam_duration
      t.string :point_block
      t.string :qualified_prereq
      t.string :optional_prereq
      t.string :mandatory_prereq
      t.boolean :active

      t.timestamps
    end
    
    add_index :courses, :course_number
    
    Course.create_translation_table!({
      :title => :string,
      :teaching_form => :text,
      :duration => :string,
      :participant_limit => :string, 
      :registration =>  :string,
      :course_objectives => :text,
			:schedule_note => :text,
      :learn_objectives => :text,
      :content => :text,
      :litteratur => :text,
      :remarks => :text,
      :top_comment => :text,
      :former_course => :string,
      :exam_form => :text,
      :exam_aid => :string,
      :evaluation_form => :string
    })
  end
    
  def down
    drop_table :courses
    Course.drop_translation_table!
  end
end



