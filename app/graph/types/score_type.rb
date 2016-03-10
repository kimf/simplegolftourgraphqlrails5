ScoreType = GraphQL::ObjectType.define do
  name "Score"
  description "A score"

  # Expose fields associated with Post model
  field :id, !types.ID, "id of the score"
  field :points, !types.Int, "How many points"
  field :event_points, !types.Int, "How many event points"

  field :created_at, !types.String, "The time at which the score was created"
  field :updated_at, !types.String, "The time at which the score was updated"

  field :user, -> { !UserType }, "Player with the score"
end
