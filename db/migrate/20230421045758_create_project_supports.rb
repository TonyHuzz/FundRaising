class CreateProjectSupports < ActiveRecord::Migration[5.2]
  def change
    create_table :project_supports do |t|
      t.belongs_to :project
      t.string :name
      t.text :description
      t.integer :price
      t.integer :status, default: 0, null: false
      t.timestamps
    end
  end
end
