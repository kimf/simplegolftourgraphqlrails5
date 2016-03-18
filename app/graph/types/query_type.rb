QueryType = GraphQL::ObjectType.define do
  name "Query"
  description "The query root of this schema. See available queries."

  # Get User by ID
  field :user do
    type !UserType
    description "Root object to get user related collections"
    argument :id, !types.ID

    # if ctx.ast_node.children.map(&:name).include?('comments')
    resolve -> (_object, args, _context) do
      User.includes(
        tours: [
          :users,
          memberships: [:user],
          seasons: [:events]
        ]
      ).find(args["id"])
    end
  end

  # Get a Tour by ID (only the current users tours)
  field :tour do
    type !TourType
    argument :id, !types.ID
    description "Get a tour"

    resolve -> (_object, args, context) do
      context[:current_user].tours.find(args["id"])
      # context[:current_user].tours.includes(
      #   :users, memberships: [:user], seasons: [:events]
      # ).find(args["id"])
    end
  end


  field :currentUser do
    type !UserType
    description "Get the logged in user and related data"
    resolve -> (_object, _args, context) do
      context[:current_user]
    end
  end

  #season
  #leaderboard
  #event
  #score
end
