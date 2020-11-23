class AddUsernamesToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :username_insta, :string
    add_column :users, :username_twitter, :string
    add_column :users, :username_linkedin, :string
    add_column :users, :username, :string
  end
end
