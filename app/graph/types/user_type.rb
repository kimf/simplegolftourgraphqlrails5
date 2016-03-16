UserType = GraphQL::ObjectType.define do
  name "User"
  description "An user entry, returns basic user information"


  interfaces [NodeIdentification.interface]
  # # `id` exposes the UUID
  global_id_field :id
  # field :id, !types.ID, "ID"

  # Expose fields from the model
  field :name, !types.String, "The name of this user"
  field :first_name, !types.String, "The first name of this user"
  field :last_name, !types.String, "The last name of this user"
  field :email, !types.String, "The email of this user"

  # Timestamps
  field :created_at, !types.String,  "The date this user created an account"
  field :updated_at, !types.String,  "The date this user updated the info"

  # Associations
  field :tours, !types[!TourType], "This users tours"
  field :scores, !types[!ScoreType], "This users scores"
  field :events, !types[!EventType], "This users events"
end
