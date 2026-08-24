class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :billetto_event_id, index: { unique: true }
      t.string :title, null: false
      t.text :description
      t.string :category
      t.string :image_url
      t.string :event_url, null: false
      t.text :address
      t.datetime :start_date, null: false

      t.timestamps
    end
  end
end
