class ChangeDataInResources < ActiveRecord::Migration[6.0]
  def change
    change_column :resources, :data, :jsonb
  end
end
