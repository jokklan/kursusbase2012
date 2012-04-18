class CreateFieldOfStudies < ActiveRecord::Migration
  def change
    create_table :field_of_studies do |t|
      t.string :title

      t.timestamps
    end
    
    add_index :field_of_studies, :title
  end
end
