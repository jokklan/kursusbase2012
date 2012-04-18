class CreateTeachers < ActiveRecord::Migration
  def change
    create_table :teachers do |t|
      t.string :name
      t.string :location
      t.string :phone
      t.string :email
      t.string :website

      t.timestamps
    end
  end
end

class AddIdInsteadOfWebsiteToTeachers < ActiveRecord::Migration
  def change
    add_column :teachers, :dtu_teacher_id, :integer
    remove_column :teachers, :website
  end
end
