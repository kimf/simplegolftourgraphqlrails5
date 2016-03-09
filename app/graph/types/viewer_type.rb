ViewerType = GraphQL::ObjectType.define do
  # HACK: to support root queries
  name "Viewer"
  description "Support unassociated root queries that fetches collections. Supports fetching tours and creators collection"
  interfaces [NodeIdentification.interface]

  # `id` exposes the UUID
  global_id_field :id

  # Fetch all posts
  connection :posts, PostType.connection_type do
    description "Post connection to fetch paginated posts collection."
    resolve ->(_object, _args, _ctx) { Tour.includes(:creator) }
  end
end
