class AddTranslationToCourseTypes < ActiveRecord::Migration
  def self.up
    CourseType.create_translation_table!({
      :title => :string
    }, {
      :migrate_data => true
    })
  end
  
  def self.down
    CourseType.drop_translation_table! :migrate_data => true
  end
end
