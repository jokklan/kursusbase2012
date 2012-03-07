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
