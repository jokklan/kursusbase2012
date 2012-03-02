class CreateInstitutes < ActiveRecord::Migration
  def up
    remove_column :courses, :institute
    add_column :courses, :institute_id, :integer
    create_table :institutes do |t|
      t.string :title

      t.timestamps
    end
  end
  def down
    add_column :courses, :institute, :string
    remove_column :courses, :institute_id
    drop_table :institutes
  end
  
end
