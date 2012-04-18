class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.string :title

      t.timestamps
    end
  end
end