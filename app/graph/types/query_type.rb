QueryType = GraphQL::ObjectType.define do
  name "Query"
  description "The query root of this schema. See available queries."

  # Get Tour by ID
  field :tour, TourType do
    argument :id, !types.ID
    description "Root object to get viewer related collections"

    resolve lambda(_obj, args, _ctx) do
      Tour.find(args["id"])
    end
  end
end
