class CreateInstitutes < ActiveRecord::Migration
  def up
    create_table :institutes do |t|
      t.integer :dtu_institute_id
      t.timestamps
    end
    
    Institute.create_translation_table!({
      :title => :string
    })
  end
  
  def down
    drop_table :institutes
    Institute.drop_translation_table
  end
  
end