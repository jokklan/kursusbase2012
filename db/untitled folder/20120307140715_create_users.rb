class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :user_id
      t.references :direction
      t.integer :start_year

      t.timestamps
    end
    add_index :users, :direction_id
  end
end

class AddCredentialsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :api_key, :string
    add_column :users, :username, :string
  end
end

class AddCnAccessKeyToUser < ActiveRecord::Migration
  def change
    add_column :users, :cn_access_key, :string
    rename_column :users, :user_id, :student_number

  end
end
