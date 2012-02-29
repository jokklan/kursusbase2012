class AddTopCommentToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :top_comment, :string
  end
end
