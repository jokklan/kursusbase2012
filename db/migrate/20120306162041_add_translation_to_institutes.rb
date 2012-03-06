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
