class AddImageAndUserIdToStudents < ActiveRecord::Migration
  def change
    add_column :students, :image, :string
    add_column :students, :user_id, :integer
  end
end
