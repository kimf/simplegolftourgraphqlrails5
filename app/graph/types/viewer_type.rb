ViewerType = GraphQL::ObjectType.define do
  # HACK: to support root queries
  name "Viewer"
  description "Support unassociated root queries that fetches collections."\
              "Supports fetching tours and creators collection."
  interfaces [NodeIdentification.interface]

  # `id` exposes the UUID
  global_id_field :id

  # Fetch all posts
  connection :tours, TourType.connection_type do
    argument :filter, types.String
    description "Tour connection to fetch paginated tours collection."
    resolve -> (_object, args, _ctx) do
      args["filter"] ? Tour.send(args["filter"]).includes(:creator) : Tour.includes(:creator)
    end
  end

  # Current user hack // Check GraphQL controller
  field :current_user, UserType do
    description "Returns current signed in user object"
    resolve -> (_obj, _args, ctx) do
      ctx[:current_user] ? ctx[:current_user] : nil
    end
  end
end
