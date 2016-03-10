class AddMissingIndexes < ActiveRecord::Migration[5.0]
  def change
    add_index :event_teams, :event_id
    add_index :users, :invitor_id
    add_index :tours, :creator_id
    add_index :scores, :event_id
    add_index :scores, [:event_id, :user_id]
    add_index :authentications, :user_id
  end
end
