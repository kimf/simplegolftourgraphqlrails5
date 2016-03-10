UserType = GraphQL::ObjectType.define do
  name "User"
  description "An user entry, returns basic user information"

  # Expose fields from the model
  field :id, !types.ID, "This id of this user"
  field :name, !types.String, "The name of this user"
  field :first_name, !types.String, "The first name of this user"
  field :last_name, !types.String, "The last name of this user"
  field :email, !types.String, "The email of this user"

  # Leaderboard stuff
  field :average, !types.Float, "average event points"
  field :num_events, !types.Int, "how many events"
  field :points_array, !types[!types.Int], "array of the top x aggregated points"
  field :position, !types.Int, "position"

  field :old_average, !types.Float, "Old average point, before comparison event"
  field :old_total_points, !types.Int, "Old total points, before comparison event"
  field :prev_position, !types.Int, "previous position"
  field :total_points, !types.Int, "total event points for this tour"

  # Timestamps
  field :created_at, !types.String,  "The date this user created an account"
  field :updated_at, !types.String,  "The date this user updated the info"

  # Associations
  field :tours, !types[!TourType], "This users tours"
  field :scores, !types[!ScoreType], "This users scores"
  field :events, !types[!EventType], "This users events"
end
