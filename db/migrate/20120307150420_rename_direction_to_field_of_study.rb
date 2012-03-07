class RenameDirectionToFieldOfStudy < ActiveRecord::Migration
  def up
    rename_table :directions, :field_of_studies
  end

  def down
    rename_table :field_of_studies, :directions
  end
end
