class ChangeDataInResources < ActiveRecord::Migration[6.0]
  def change
    remove_column :resources, :data
    add_column :resources, :data, :jsonb
  end
end
