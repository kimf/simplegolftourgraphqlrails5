MembershipType = GraphQL::ObjectType.define do
  name "Membership"
  description "An Membership entry, returns basic information"
  # Expose fields from the model
  field :id, !types.ID, "This id of this membership"

  field :nickname, !types.String, "The nickname of the user for this membership"
  field :role, !types.String, "The role of this membership"

  field :created_at, !types.String,  "The date this membership created an account"
  field :updated_at, !types.String,  "The date this membership updated the info"

  field :user, !UserType, "User of this membership"
end
