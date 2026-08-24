class AddNotNullConstraintsToEvents < ActiveRecord::Migration[8.1]
  def change
    change_column_null :events, :billetto_event_id, false
    change_column_null :events, :title, false
    change_column_null :events, :event_url, false
    change_column_null :events, :start_date, false
  end
end
