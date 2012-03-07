class RenameKeywordToTitle < ActiveRecord::Migration
  def up
    rename_column :keyword_translations, :keyword, :title
  end

  def down
    rename_column :keyword_translations, :title, :keyword
  end
end
