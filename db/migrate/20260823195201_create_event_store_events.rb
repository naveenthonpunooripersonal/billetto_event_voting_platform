class CreateEventStoreEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :event_store_events, id: :uuid do |t|
      t.string :event_type, null: false
      t.jsonb :data, null: false
      t.jsonb :metadata
      t.datetime :created_at, null: false
      t.datetime :valid_at
    end

    create_table :event_store_events_in_streams, id: :uuid do |t|
      t.uuid :event_id, null: false
      t.string :stream, null: false
      t.integer :position
      t.datetime :created_at, null: false
    end

    add_index(
      :event_store_events_in_streams,
      [:stream, :position],
      unique: true
    )
  end
end
