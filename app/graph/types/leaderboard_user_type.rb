LeaderboardUserType = GraphQL::ObjectType.define do
  name "LeaderboardUserType"
  description "An user entry, returns basic user information"

  field :db_id do
    type !types.ID

    resolve -> (object, _args, _context) do
      object.id
    end
  end

  field :id do
    type !types.ID

    resolve -> (_object, _args, _context) do
      SecureRandom.uuid
    end
  end

  field :name, !types.String, "The name of this user"

  # Leaderboard stuff
  field :average, !types.Float, "average event points"
  field :num_events, !types.Int, "how many events"
  field :points_array, !types[!types.Int], "array of the top x aggregated points"
  field :position, !types.Int, "position"

  field :old_average, !types.Float, "Old average point, before comparison event"
  field :old_total_points, !types.Int, "Old total points, before comparison event"
  field :prev_position, !types.Int, "previous position"
  field :total_points, !types.Int, "total event points for this tour"
end
