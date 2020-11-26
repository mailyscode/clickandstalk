class RenameUserToResources < ActiveRecord::Migration[6.0]
  def change
    rename_column :resources, :users_id, :user_id
  end
end
