class CreateFieldOfStudies < ActiveRecord::Migration
  def change
    create_table :field_of_studies do |t|

      t.timestamps
    end

		FieldOfStudy.create_translation_table!({
      :title => :string
    })
    
    add_index :field_of_study_translations, :title
  end
end
