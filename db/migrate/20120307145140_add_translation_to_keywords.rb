class AddTranslationToKeywords < ActiveRecord::Migration
  def self.up
    Keyword.create_translation_table!({
      :title => :string
    }, {
      :migrate_data => true
    })
  end
  
  def self.down
    Keyword.drop_translation_table! :migrate_data => true
  end
end
