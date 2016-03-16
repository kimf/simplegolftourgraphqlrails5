EventType = GraphQL::ObjectType.define do
  name "Event"
  description "A event with it\"s scores"

  #field :id, !types.ID, "id of the event"
  interfaces [NodeIdentification.interface]
  # # `id` exposes the UUID
  global_id_field :id

  field :course, !types.String, "at what course are the event"
  field :gametype, !types.String, "what gametype are they playing"
  field :scoring_type, !types.String, "Scorint type of the event"
  field :starts_at, !types.String, "The time at which the event starts"
  field :status, !types.String, "Status of the event"
  field :team_event, !types.Boolean, "Is it a team event?"

  field :created_at, !types.String, "The time at which the event was created"
  field :updated_at, !types.String, "The time at which the event was updated"

  field :scores, -> { !types[!ScoreType] }, "Scores"
end
