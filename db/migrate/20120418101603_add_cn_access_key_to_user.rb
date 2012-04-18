class AddCnAccessKeyToUser < ActiveRecord::Migration
  def change
    add_column :users, :cn_access_key, :string
    rename_column :users, :user_id, :student_number

  end
end
