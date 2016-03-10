QueryType = GraphQL::ObjectType.define do
  name "Query"
  description "The query root of this schema. See available queries."

  # Get User by ID
  field :user do
    type UserType
    description "Root object to get user related collections"
    argument :id, !types.ID

    # if ctx.ast_node.children.map(&:name).include?('comments')
    resolve -> (_object, args, context) do
      User.includes(
        tours: [
          :users,
          memberships: [:user],
          seasons: [:events]
        ]
      ).find(args["id"])
    end
  end
end
