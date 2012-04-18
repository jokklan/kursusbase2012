class CreateKeywords < ActiveRecord::Migration
  def up
    create_table :keywords do |t|

      t.timestamps
    end
    
    Keyword.create_translation_table!({
      :title => :string
    })
    
    create_table :courses_keywords do |t|
      t.integer :keyword_id
      t.integer :course_id
    end
  end
  
  def down
    drop_table :keywords
    drop_table :courses_keywords
    Keyword.drop_translation_table!
  end
end
