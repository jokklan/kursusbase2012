class CreateFlagModelTypes < ActiveRecord::Migration
  def change
    create_table :flag_model_types do |t|
			t.string :title

      t.timestamps
    end
  end
end
