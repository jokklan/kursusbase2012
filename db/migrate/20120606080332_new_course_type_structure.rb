class NewCourseTypeStructure < ActiveRecord::Migration
  def up
		create_table :spec_course_types do |t|
			t.references :course_type_type
      t.references :field_of_study
			t.references :flag_model_type

      t.timestamps
    end
		add_index :spec_course_types, :field_of_study_id
		add_index :spec_course_types, :flag_model_type_id
		add_index :spec_course_types, :course_type_type_id

		create_table :main_course_types do |t|
			
      t.timestamps
    end

		MainCourseType.create_translation_table!({
      :title => :string
    })

		create_table :course_specializations do |t|
			t.references :course
      t.references :spec_course_type
      t.boolean :optional, :default => false
      t.string :recommended_semester

      t.timestamps
    end
    add_index :course_specializations, :spec_course_type_id

		create_table :courses_main_course_types do |t|
			t.references :course
			t.references :main_course_type
		end
		add_index :courses_main_course_types, :course_id
		add_index :courses_main_course_types, :main_course_type_id

  end

  def down
		drop_table :spec_course_types
		drop_table :main_course_types
		drop_table :course_specializations
		drop_table :courses_main_course_types
  end
end
