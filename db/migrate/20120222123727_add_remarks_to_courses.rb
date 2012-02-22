class AddRemarksToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :remarks, :string
  end
end
