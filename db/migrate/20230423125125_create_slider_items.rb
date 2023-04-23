class CreateSliderItems < ActiveRecord::Migration[5.2]
  def change
    create_table :slider_items do |t|
      t.string :title
      t.string :url
      t.text :description
      t.string :cover_image
      t.integer :order_index, default: 10, null: false
      t.integer :status, default: 0, null: false
      t.timestamps
    end

    add_index :slider_items, :order_index
    add_index :slider_items, :status
  end
end
