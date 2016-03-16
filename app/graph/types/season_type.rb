SeasonType = GraphQL::ObjectType.define do
  name "Season"
  description "A season with it\"s events"

  field :id, !types.ID, "id of the season"

  field :aggregate_count, !types.Int, "season"
  field :points_ladder, !types[!types.Int], "points ladder for this season"
  field :use_reversed_points, !types.Boolean, "Does the season use reversed points"
  field :closed_at, types.String, "The time at which the season was CLOSED"
  field :created_at, !types.String, "The time at which the season was created"
  field :updated_at, !types.String, "The time at which the season was updated"
  field :leaderboard, -> { !types[!LeaderboardUserType] }, "Leaderboard for season"
  field :events, -> { !types[!EventType] }, "Events"
end
