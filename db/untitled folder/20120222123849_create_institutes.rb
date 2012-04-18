class CreateInstitutes < ActiveRecord::Migration
  def up
    remove_column :courses, :institute
    add_column :courses, :institute_id, :integer
    create_table :institutes do |t|
      t.string :title
      t.integer :dtu_institute_id
      t.timestamps
    end
  end
  def down
    add_column :courses, :institute, :string
    remove_column :courses, :institute_id
    drop_table :institutes
  end
  
end

class AddTranslationToInstitutes < ActiveRecord::Migration
  def self.up
    Institute.create_translation_table!({
      :title => :string
    }, {
      :migrate_data => true
    })
  end
  
  def self.down
    Institute.drop_translation_table! :migrate_data => true
  end
end