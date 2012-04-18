class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :student_number
      t.references :direction
      t.integer :start_year
      t.string :cn_access_key

      t.timestamps
    end
    
    add_index :users, :student_number
    
    create_table :course_users do |t|
      t.references :user
      t.references :course
      t.string :semester
    end
    
    add_index :course_users, :user_id
    add_index :course_users, :course_id
    
  end
end