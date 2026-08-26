class CreateEventVoteCounts < ActiveRecord::Migration[8.1]
  def change
    create_table :event_vote_counts do |t|
      t.references :event, null: false, foreign_key: true

      t.integer :likes_count, null: false, default: 0
      t.integer :dislikes_count, null: false, default: 0

      t.timestamps
    end

    add_index :event_vote_counts, :event_id, unique: true, name: "event_vote_counts_on_event_id_index"
  end
end
