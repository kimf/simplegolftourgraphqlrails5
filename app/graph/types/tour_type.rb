TourType = GraphQL::ObjectType.define do
  name "Tour"
  description "A tour with it\"s seasons, events, players, and leaderboards"

  # Expose fields associated with Post model
  field :id, types.ID, "id of the tour"
  field :name, types.String, "The name of the tour"
  field :custom_domain, types.String, "The custom domain of the tour"
  field :use_custom_domain, types.Boolean, "Is the tour using custom domain?"
  field :custom_logo_url, types.String, "Url to the tours custom logo. for whitelabeling"
  field :created_at, types.String, "The time at which the tour was created"
  field :updated_at, types.String, "The time at which the tour was updated"
  field :creator, UserType, "Creator of the tour"
end
