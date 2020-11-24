class AddOauthToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :linked_oauth_data, :jsonb
    add_column :users, :twitter_oauth_data, :jsonb
  end
end
