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
