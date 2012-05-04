class AddIndexToKeywords < ActiveRecord::Migration
  def change
		add_index :keyword_translations, :title
  end
end
