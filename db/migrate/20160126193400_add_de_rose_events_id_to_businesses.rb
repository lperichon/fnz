class AddDeRoseEventsIdToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :derose_events_id, :integer
  end
end
