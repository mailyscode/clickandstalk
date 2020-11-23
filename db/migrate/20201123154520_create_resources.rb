class CreateResources < ActiveRecord::Migration[6.0]
  def change
    create_table :resources do |t|
      t.string :data_type
      t.string :data
      t.references :users, null: false, foreign_key: true

      t.timestamps
    end
  end
end
