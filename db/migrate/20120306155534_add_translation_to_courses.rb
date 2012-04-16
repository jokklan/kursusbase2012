class AddTranslationToCourses < ActiveRecord::Migration
  
  def self.up
    Course.create_translation_table!({
      :title => :string,
      :teaching_form => :text,
      :duration => :string,
      :participant_limit => :string, 
      :registration =>  :string,
      :course_objectives => :text,
      :learn_objectives => :text,
      :content => :text,
      :litteratur => :text,
      :remarks => :text,
      :top_comment => :text
    }, {
      :migrate_data => true
    })
  end
  
  def self.down
    Course.drop_translation_table! :migrate_data => true
  end
  
end