class AddCredentialsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :api_key, :string
    add_column :users, :username, :string
  end
end
