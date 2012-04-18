class CreateTeachers < ActiveRecord::Migration
  def change
    create_table :teachers do |t|
      t.string :name
      t.string :location
      t.string :phone
      t.string :email
      t.integer :dtu_teacher_id

      t.timestamps
    end
    
    create_table :courses_teachers do |t|
      t.integer :teacher_id
      t.integer :course_id
    end
  end
end
